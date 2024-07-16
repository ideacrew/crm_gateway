# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'date'

module SugarCRM
  module Operations
    module Payload
      # Contact Operation
      class Contact
        include Dry::Monads[:result, :do, :try]

        def call(payload, relationship_to_primary = "Self")
          dob = SugarCRM::Operations::Payload::Dob.new.call(payload.dig(:person, :person_demographics, :dob))
          phone_number = SugarCRM::Operations::Payload::PhoneNumber.new.call(payload.dig(:person, :phones))
          hbx_id = yield SugarCRM::Operations::Payload::HbxId.new.call(payload)
          Success(
            hbxid_c: hbx_id,
            first_name: payload.dig(:person, :person_name, :first_name),
            last_name: payload.dig(:person, :person_name, :last_name),
            phone_mobile: phone_number.success,
            email1: payload.dig(:person, :emails, 0, :address),
            birthdate: dob.success,
            relationship_c: relationship_to_primary
          )
        end
      end
    end
  end
end
