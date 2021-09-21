# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require_relative "../../sugar_crm/services/connection"

module SugarCRM
  module Operations
    # class for creating or updating a primary account and contact
    class PrimaryUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :hbx_id

      def call(payload:)
        hbx_id = payload[:hbx_id]
        account = SugarCRM::Operations::CreateOrUpdateAccount.new
        results = account.call(
          hbx_id: hbx_id,
          params: payload_to_account_params(payload)
        )
        account_id = account.id

        results += SugarCRM::Operations::CreateOrUpdateContact.new.call(
          hbx_id: hbx_id,
          params: payload_to_contact_params(payload).merge(account_id: account_id)
        )

        if results.map(&:first).all? do |(step, result)|
          step =~ /create|update/ && result.success?
        end
          Success(results)
        else
          Failure(results)
        end
      end

      def payload_to_contact_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          first_name: payload[:person_name][:first_name],
          last_name: payload[:person_name][:last_name],
          phone_mobile: mobile_phone_finder(payload[:phones]), #spec
          email1: payload.dig(:emails, 0, :address),
          birthdate: convert_dob_to_string(payload.dig(:person_demographics, :dob)),
          relationship_c: 'Self'
        }
      end

      def convert_dob_to_string(dob)
        date = Date.parse(dob.to_s)
        date.strftime("%Y-%m-%d")
      end

      def mobile_phone_finder(payload)
        phone_number = payload.detect { |number| number[:kind] == 'mobile' } ||
                       payload.detect { |number| number[:kind] == 'home' } ||
                       payload.first
        phone_formatter phone_number
      end

      def phone_formatter(phone)
        return nil unless phone

        if phone[:area_code] && phone[:number]
          "(#{phone[:area_code]}) #{phone[:number].first(3)}-#{phone[:number][3..-1]}"
        elsif phone[:full_number].length == 10
          "(#{phone[:full_number].first(3)}) #{phone[:full_number][3..5]}-#{phone[:full_number][6..-1]}"
        else
          phone[:full_number]
        end
      end

      def payload_to_account_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          name: payload[:person_name][:full_name],
          email1: payload.dig(:emails, 0, :address),
          billing_address_street: payload.dig(:addresses, 0, :address_1),
          billing_address_street_2: payload.dig(:addresses, 0, :address_2),
          billing_address_street_3: payload.dig(:addresses, 0, :address_3),
          billing_address_street_4: payload.dig(:addresses, 0, :address_4),
          billing_address_city: payload.dig(:addresses, 0, :city),
          billing_address_postalcode: payload.dig(:addresses, 0, :zip),
          billing_address_state: payload.dig(:addresses, 0, :state),
          phone_office: mobile_phone_finder(payload[:phones]),
          raw_ssn_c: payload[:person_demographics][:ssn],
          dob_c: convert_dob_to_string(payload.dig(:person_demographics, :dob))
        }
      end
    end
  end
end
