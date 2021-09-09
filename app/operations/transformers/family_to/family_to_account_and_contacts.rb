# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'aca_entities/magi_medicaid/libraries/iap_library'

module Operations
  module Transformers
    module FamilyTo
      # Transforms family payload from Enroll into Accounts/Contacts for Sugar CRM
      class AccountAndContacts
        # Constructs cv3 payload including family and FA Application

        include Dry::Monads[:result, :do]
        require 'securerandom'

        def call(family_payload)
          convert_payload(family_payload)
        end

        private

        def convert_payload(family_payload)
          family = family_payload.to_h
          payload = {}
          account_params = to_account(family_payload)
          payload.merge!(account_params)
          payload[:contacts] = []
          family_payload[:family_members].each do |family_member|
            payload[:contacts] << to_contact(family_member)
          end
          payload
        end

        def to_account(family_hash)
          primary_family_member = family_hash[:family_members].detect { |fm| fm[:is_primary_applicant] == true }
          payload = {
            name: primary_family_member[:person][:person_name][:full_name],
            contacts_count: family_hash[:family_members].count,
            opportunities_count: 0,
            email: primary_family_member[:person][:emails].first[:address],
            alt_email: primary_family_member[:person][:emails].length > 1 ? primary_family_member[:person][:emails][1][:address] : nil,
            phone: primary_family_member[:person][:phones].first[:full_phone_number],
            mobile: "",
            date_of_birth: primary_family_member[:person][:person_demographics][:dob]&.to_date,
          }
        end

        def to_contact(family_member_hash)
          payload = {
            first_name: family_member_hash[:person][:person_name][:first_name],
            last_name: family_member_hash[:person][:person_name][:last_name],
            date_of_birth: family_member_hash[:person][:person_demographics][:dob]&.to_date,
            gender: family_member_hash[:person][:person_demographics][:gender],
            preferrred_language: "",
            email: family_member_hash[:person][:emails]&.first[:address],
            ssn: family_member_hash[:person][:person_demographics][:ssn],
          }
        end
      end
    end
  end
end
