# frozen_string_literal: true

require 'dry/monads'
# require 'aca_entities/magi_medicaid/libraries/iap_library'

module Operations
  module Transformers
    module FamilyTo
      # Transforms family payload from Enroll into Accounts/Contacts for Sugar CRM
      class AccountAndContacts
        # Constructs cv3 payload including family and FA Application

        include Dry::Monads[:result, :do]
        require 'securerandom'

        def call(family_payload)
          @family_payload = family_payload
          payload = to_account
          payload[:contacts] = []
          family[:family_members].each do |family_member|
            payload[:contacts] << to_contact(family_member.with_indifferent_access, primary_family_member)
          end
        end

        private

        def primary_family_member
          @primary_family_member ||= @family_payload[:family_members].detect { |fm| fm[:is_primary_applicant] == true }
        end

        def primary_family_member_hbx_id
          primary_family_member[:hbx_id]
        end

        def to_account
          {
            primary_person_hbx_id: primary_family_member[:hbx_id],
            name: primary_family_member[:person][:person_name][:full_name],
            contacts_count: @family_payload[:family_members].count,
            opportunities_count: 0,
            email: primary_family_member[:person][:emails].first[:address],
            alt_email: primary_family_member[:person][:emails].length > 1 ? primary_family_member[:person][:emails][1][:address] : nil,
            phone: primary_family_member[:person][:phones].first[:full_phone_number],
            mobile: '',
            date_of_birth: primary_family_member[:person][:person_demographics][:dob]&.to_date
          }.with_indifferent_access
        end

        def to_contact(family_member_hash)
          {
            hbx_id: family_member_hash[:person][:hbx_id],
            first_name: family_member_hash[:person][:person_name][:first_name],
            last_name: family_member_hash[:person][:person_name][:last_name],
            date_of_birth: family_member_hash[:person][:person_demographics][:dob]&.to_date,
            gender: family_member_hash[:person][:person_demographics][:gender],
            preferrred_language: '',
            email: family_member_hash[:person][:emails]&.first&.[](:address),
            ssn: family_member_hash[:person][:person_demographics][:ssn],
            relationship_to_primary: find_relationship(family_member_hash)
          }
        end

        #rubocop:disable Lint/ShadowingOuterLocalVariable
        def find_relationship(family_member_hash)
          relationship = family_member_hash[:person][:person_relationships].detect do |relationship|
            puts (relationship[:relative][:hbx_id] == primary_family_member_hbx_id).inspect
            relationship[:relative][:hbx_id] == primary_family_member_hbx_id
          end
          relationship[:kind]
        end
        #rubocop:enable Lint/ShadowingOuterLocalVariable
      end
    end
  end
end
