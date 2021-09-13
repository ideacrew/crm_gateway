require 'dry/monads'
require 'dry/monads/do'
require_relative "../../sugar_crm/services/connection"

module SugarCRM
  module Operations
    class PrimaryUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :event

      def call(payload:)
        existing_account = find_existing_account(
          hbx_id: payload[:hbx_id]
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
          hbx_id: payload[:hbx_id],
          first_name: payload[:first_name],
          last_name: payload[:last_name]
        }
      end

      def payload_to_account_params(payload)
        {
          hbx_id: payload[:hbx_id],
          first_name: payload[:first_name],
          last_name: payload[:last_name]
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
          payload_to_account_params(payload)
        )
        Failure("Couldn't create account") unless account

        contact = service.create_contact_for_account(
          **payload_to_contact_params(payload), account_id: account
        )
        Failure("Couldn't create contact") unless contact
        Success(contact)
      end

      def update_account(hbx_id:, first_name:, last_name:)
        account = service.update_account(
          hbx_id: hbx_id,
          first_name: first_name,
          last_name: last_name
        )
        Failure("Couldn't update account") unless account
        Success(account)
      end

      def update_contact(hbx_id:, first_name:, last_name:)
        contact = service.update_contact(
          hbx_id: hbx_id,
          first_name: first_name,
          last_name: last_name
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
