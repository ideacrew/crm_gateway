# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'aca_entities/magi_medicaid/libraries/iap_library'

module Operations
  module Transformers
    module PersonTo
      # Transforms family payload from Enroll into Accounts/Contacts for Sugar CRM
      class Contact
        # Constructs cv3 payload including family and FA Application

        include Dry::Monads[:result, :do]
        require 'securerandom'

        def call(person_payload)
          convert_payload(person_payload)
        end

        private

        def convert_payload(person_payload)
          pereson_payload = person_payload.to_h
          payload = {}
          payload.merge!(to_contact(pereson_payload))
        end

        def to_contact(person_hash)
          payload = {
            hbx_id: person_hash[:hbx_id],
            first_name: person_hash[:person_name][:first_name],
            last_name: person_hash[:person_name][:last_name],
            date_of_birth: person_hash[:person_demographics][:dob]&.to_date,
            gender: person_hash[:person_demographics][:gender],
            preferred_language: '',
            email: person_hash[:emails]&.first[:address],
            ssn: person_hash[:person_demographics][:ssn]
          }
        end
      end
    end
  end
end