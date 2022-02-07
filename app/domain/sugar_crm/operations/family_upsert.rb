# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"
require 'date'

module SugarCRM
  module Operations
    # class for creating or updating a family
    class FamilyUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :primary_family_member_hbx_id, :payload

      def call(payload:)
        @payload = payload.deep_symbolize_keys
        existing_account = find_existing_account(
          hbx_id: primary_person[:hbx_id]
        )
        if existing_account.success?
          update_account(existing_account.value!)
        else
          existing_account = create_account
        end
        return Failure(existing_account.failure) if existing_account.failure?
        results = @payload[:family_members].map do |family_member|
          family_member_hbx_id = family_member[:hbx_id]
          existing_contact = service.find_contact_by_hbx_id(family_member_hbx_id)
          if existing_contact
            update_existing_contact(id: existing_contact, account_id: existing_account.value!, params: family_member)
          else
            create_contact(account_id: existing_account.value!, params: family_member)
          end
        end
        if failing_result = results.detect(&:failure?)
          Failure(failing_result.failure)
        else
          Success("Successful family update")
        end
      rescue Faraday::ConnectionFailed => e
        Failure(error: "couldn't connect to host", error_message: e.message, error_backtrace: e.backtrace)
      rescue StandardError => e
        Failure(error: 'Unknown error', error_message: e.message, error_backtrace: e.backtrace)
      end

      def primary_person
        @payload[:family_members].detect do |family_member|
          family_member[:is_primary_applicant] == true
        end
      end

      def find_existing_account(hbx_id:)
        if existing_account = service.find_account_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure(error: "no account found", error_message: "No account found")
        end
      end

      def person_relationship_finder(hbx_id_to_match)
        return "Self" if hbx_id_to_match == primary_person[:hbx_id]

        matched_relative = primary_person[:person][:person_relationships].detect do |relative_hash|
          relative_hash[:relative][:hbx_id] == hbx_id_to_match
        end
        Rails.logger.debug { "matched relative #{matched_relative}" }
        matched_relative[:kind].titleize
      end

      def update_existing_contact(id:, account_id:, params:)
        hbx_id_to_match = SugarCRM::Operations::Payload::HbxId.new.call(params).value!
        relationship_to_primary = person_relationship_finder(hbx_id_to_match)
        payload = yield SugarCRM::Operations::Payload::Contact.new.call(params, relationship_to_primary)
        result = service.update_contact(
          id: id,
          payload: payload.merge(account_id: account_id)
        )
        if result
          Success(result)
        else
          Failure("Couldn't update contact")
        end
      end

      def create_contact(account_id:, params:)
        hbx_id_to_match = SugarCRM::Operations::Payload::HbxId.new.call(params).value!
        relationship_to_primary = person_relationship_finder(hbx_id_to_match)
        contact_payload = yield SugarCRM::Operations::Payload::Contact.new.call(params, relationship_to_primary)
        contact = service.create_contact_for_account(
          payload: contact_payload.merge(account_id: account_id)
        )
        return Failure("Couldn't create contact") unless contact
        Success(contact)
      end

      def update_account(id)
        primary_person_payload = primary_person.merge(primary_person.slice(:hbx_id))
        account_params = yield SugarCRM::Operations::Payload::Account.new.call(primary_person_payload)
        account = service.update_account(
          id: id,
          payload: account_params
        )
        return Failure("Couldn't update account") unless account
        Success(account)
      end

      def create_account
        primary_person_payload = primary_person.merge(primary_person.slice(:hbx_id))
        account_params = yield SugarCRM::Operations::Payload::Account.new.call(primary_person_payload)
        account = service.create_account(payload: account_params)
        return Failure("Couldn't create account") unless account
        Success(account['id'])
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
