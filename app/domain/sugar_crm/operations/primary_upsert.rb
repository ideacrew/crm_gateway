require 'dry/monads'
require 'dry/monads/do'
require_relative "../../sugar_crm/services/connection"

module SugarCRM
  module Operations
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
            payload_to_contact_params(payload)
          )
        else
          yield create_account_and_contact(
            payload
          )
        end
        Success(result)
      end

      def payload_to_contact_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          first_name: payload[:person_name][:first_name],
          last_name: payload[:person_name][:last_name],
          phone_mobile: mobile_phone_finder(payload[:phones]), #spec
          email1: payload[:emails].first[:address]
        }
      end

      def mobile_phone_finder(payload)
        phone_number = payload.detect { |number| number[:kind] == 'mobile' } || 
          payload.detect { |number| number[:kind] == 'home' } ||
          payload.first
        phone_number[:full_phone_number]
      end

      def payload_to_account_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          name: "#{payload[:person_name][:first_name]} #{payload[:person_name][:last_name]}",
          email1: payload[:emails].first[:address],
          dob_c: payload[:person_demographics][:dob],
          billing_address_street: payload[:addresses].first[:address_1],
          billing_address_street_2: payload[:addresses].first[:address_2],
          billing_address_street_3: payload[:addresses].first[:address_3],
          billing_address_street_4: payload[:addresses].first[:address_4],
          billing_address_city: payload[:addresses].first[:city],
          billing_address_postalcode: payload[:addresses].first[:zip],
          billing_address_state: payload[:addresses].first[:state],
          phone_office: mobile_phone_finder(payload[:phones]),
          raw_ssn_c: payload[:person_demographics][:ssn]
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
          payload: { **payload_to_contact_params(payload), 'account.id': account }
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
