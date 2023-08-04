# frozen_string_literal: true

module SugarCRM
  module Operations
    module Families
      # Invoke a Family update service and update/create their corresponding contact records
      class HandleFamilyUpdate
        include Dry::Monads[:result, :do, :try]
        include EventSource::Command
        require 'dry/monads'
        require 'dry/monads/do'
        require 'aca_entities/crms/accounts/account'
        require 'aca_entities/crms/contracts/accounts/account_contract'
        require 'aca_entities/crms/contracts/contacts/contact_contract'
        require 'aca_entities/crms/contacts/contact'

        attr_reader :event_log

        # @return [Dry::Monads::Result]
        def call(family_payload, event_retry = nil)
          family_payload = JSON.parse(family_payload).with_indifferent_access if family_payload.instance_of?(String)
          @event_log = event_retry || ::Event.create(
            event_name_identifier: 'Family Update',
            data: family_payload
          )
          @event_log.process!
          sleep 3 # sometimes primary and family follow behind each other to quick
          result = publish_to_crm(family_payload)
          if result.success?
            @event_log.complete!
            Success("Update the family")
          else
            @event_log.error = result.failure[:error]
            @event_log.error_message = result.failure[:error_message]
            @event_log.error_backtrace = result.failure[:error_backtrace]
            @event_log.fail!
          end
          result
        end

        protected

        def publish_to_crm(validated_payload)
          Rails.logger.debug validated_payload
          SugarCRM::Operations::FamilyUpsert.new.call(payload: validated_payload)
        end

        # Famlily Payload is a Hash
        def build_accounts_and_contacts(family_payload)
          family = family_payload.to_h.with_indifferent_access
          primary_family_member = family[:family_members].detect { |fm| fm[:is_primary_applicant] == true }
          payload = {}.with_indifferent_access
          account_params = to_account(family, primary_family_member)
          payload.merge!(account_params)
          payload[:contacts] = []
          family[:family_members].each do |family_member|
            payload[:contacts] << to_contact(family_member.with_indifferent_access, primary_family_member)
          end
          payload
        end

        def to_account(family_hash, primary_family_member)
          {
            primary_person_hbx_id: primary_family_member[:hbx_id],
            name: primary_family_member[:person][:person_name][:full_name],
            contacts_count: family_hash[:family_members].count,
            opportunities_count: 0,
            email: primary_family_member[:person][:emails].first[:address],
            alt_email: primary_family_member[:person][:emails].length > 1 ? primary_family_member[:person][:emails][1][:address] : nil,
            phone: primary_family_member[:person][:phones].first[:full_phone_number],
            mobile: '',
            date_of_birth: primary_family_member[:person][:person_demographics][:dob]&.to_date
          }.with_indifferent_access
        end

        def to_contact(family_member_hash, primary_family_member)
          relationship_to_primary = if family_member_hash[:is_primary_applicant] == true
                                      "self"
                                    else
                                      primary_family_member[:person][:person_relationships].detect { |relative_hash| relative_hash[:relative][:hbx_id] == family_member_hash[:person][:hbx_id] }[:kind]
                                    end
          {
            hbx_id: family_member_hash[:person][:hbx_id],
            first_name: family_member_hash[:person][:person_name][:first_name],
            last_name: family_member_hash[:person][:person_name][:last_name],
            date_of_birth: family_member_hash[:person][:person_demographics][:dob]&.to_date,
            gender: family_member_hash[:person][:person_demographics][:gender],
            preferrred_language: '',
            email: family_member_hash.dig(:person, :emails, 0, :address),
            ssn: family_member_hash.dig(:person, :person_demographics, :ssn),
            relationship_to_primary: relationship_to_primary
          }.with_indifferent_access
        end

        def validate_contacts_and_accounts(initialized_contacts_and_accounts)
          account_validation_and_contract_validation = Crms::Accounts::AccountContract.new.call(initialized_contacts_and_accounts)
          account_validation_and_contract_validation.success? ? Success(account_validation_and_contract_validation.to_h) : Failure(account_validation_and_contract_validation.errors.to_h)
        end
      end
    end
  end
end