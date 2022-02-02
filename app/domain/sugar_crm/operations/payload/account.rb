# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"
require 'date'

include FormatHelper

module SugarCRM
  module Operations
    module Payload
      class Account
        include Dry::Monads[:result, :do, :try]

        def call(payload)
          hbx_id = yield SugarCRM::Operations::Payload::HbxId.new.call(payload)
          phone_number = SugarCRM::Operations::Payload::PhoneNumber.new.call(payload.dig(:person, :phones)).success
          raw_ssn = decrypt_ssn(payload).success
          dob = SugarCRM::Operations::Payload::Dob.new.call(payload.dig(:person, :person_demographics, :dob)).success
          Success(
            hbxid_c: hbx_id,
            name: payload.dig(:person, :person_name, :full_name),
            email1: payload.dig(:person, :emails, 0, :address),
            billing_address_street: payload.dig(:person, :addresses, 0, :address_1),
            billing_address_street_2: payload.dig(:person, :addresses, 0, :address_2),
            billing_address_street_3: payload.dig(:person, :addresses, 0, :address_3),
            billing_address_street_4: payload.dig(:person, :addresses, 0, :address_4),
            billing_address_city: payload.dig(:person, :addresses, 0, :city),
            billing_address_postalcode: payload.dig(:person, :addresses, 0, :zip),
            billing_address_state: payload.dig(:person, :addresses, 0, :state),
            phone_office: phone_number,
            rawssn_c: raw_ssn,
            raw_ssn_c: raw_ssn,
            dob_c: dob,
            enroll_account_link_c: payload.dig(:person, :external_person_link)
          )
        end

        def hbx_id(payload)
          payload[:hbx_id] ? Success(payload[:hbx_id]) : Failure("No HBX ID found")
        end

        

        def decrypt_ssn(payload)
          encrypted_ssn = payload.dig(:person, :person_demographics, :encrypted_ssn)
          return Failure("No SSN") unless encrypted_ssn
          AcaEntities::Operations::Encryption::Decrypt.new.call(value: encrypted_ssn)
        rescue StandardError => e
          Rails.logger.warn "Could not decrypt SSN with RBNACL_SECRET_KEY: #{AcaEntities::Configuration::Encryption.config.secret_key} RBNACL_IV: #{AcaEntities::Configuration::Encryption.config.iv}"
          Failure(e)
        end
      end
    end
  end
end