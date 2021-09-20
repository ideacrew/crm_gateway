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
        @hbx_id = payload[:hbx_id]
        existing_account = find_existing_account(
          hbx_id: @hbx_id
        )
        result = if existing_account.success?
                   yield update_account(
                     payload_to_account_params(payload)
                   )
                   yield update_contact(
                     payload_to_contact_params(payload.merge('account.id': existing_account.value!))
                   )
                 else
                   yield create_account_and_contact(
                     payload
                   )
                 end
        Success(result)
      rescue Faraday::ConnectionFailed => e
        Failure(error: "couldn't connect to host", error_message: e.message, error_backtrace: e.backtrace)
      rescue StandardError => e
        Failure(error: 'Unknown error', error_message: e.message, error_backtrace: e.backtrace)
      end

      def payload_to_contact_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          first_name: payload[:person_name][:first_name],
          last_name: payload[:person_name][:last_name],
          phone_mobile: mobile_phone_finder(payload[:phones]), #spec
          email1: payload.dig(:emails, 0, :address),
          birthdate: convert_dob_to_string(payload.dig(:person_demographics, :dob)),
          relationship_c: 'self'
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
        phone_number&.dig(:full_phone_number)
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

      def find_existing_account(hbx_id:)
        if existing_account = service.find_account_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure("No account found")
        end
      end

      def create_account_and_contact(payload)
        account = service.create_account(
          payload: payload_to_account_params(payload)
        )
        Failure("Couldn't create account") unless account

        contact = service.create_contact_for_account(
          payload: payload_to_contact_params(payload).merge(account_id: account)
        )
        Failure("Couldn't create contact") unless contact
        Success(contact)
      end

      def update_account(payload)
        account = service.update_account(
          hbx_id: @hbx_id,
          payload: payload
        )
        Failure("Couldn't update account") unless account
        Success(account)
      end

      def update_contact(payload)
        contact = service.update_contact_by_hbx_id(
          hbx_id: @hbx_id,
          payload: payload
        )
        Failure("Couldn't update contact") unless contact
        Success(contact)
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
