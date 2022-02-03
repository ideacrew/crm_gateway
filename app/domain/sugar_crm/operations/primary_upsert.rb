# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"

module SugarCRM
  module Operations
    # class for creating or updating a primary account and contact
    class PrimaryUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :hbx_id

      def call(payload:)
        @hbx_id = yield  SugarCRM::Operations::Payload::HbxId.new.call(payload)
        existing_account = find_existing_account(
          hbx_id: @hbx_id
        )
        result = if existing_account.success?
                   yield update_account(existing_account.value!, SugarCRM::Operations::Payload::Account.new.call(payload))
                 else
                   yield create_account(SugarCRM::Operations::Payload::Account.new.call(payload))
                 end
        existing_contact = find_existing_contact(
          hbx_id: @hbx_id
        )
        contact_result = if existing_contact.success?
                           yield update_contact(
                             existing_contact.value!, SugarCRM::Operations::Payload::Contact.new.call(payload.merge('account.id': result['id']))
                           )
                         else
                           yield create_contact(
                             SugarCRM::Operations::Payload::Contact.new.call(payload.merge('account.id': result['id']))
                           )
                         end
        Success(contact_result)
      rescue Faraday::ConnectionFailed => e
        Failure(error: "couldn't connect to host", error_message: e.message, error_backtrace: e.backtrace)
      rescue StandardError => e
        Failure(error: 'Unknown error', error_message: e.message, error_backtrace: e.backtrace)
      end

      def find_existing_account(hbx_id:)
        if existing_account = service.find_account_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure("No account found")
        end
      end

      def find_existing_contact(hbx_id:)
        if existing_account = service.find_contact_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure("No contact found")
        end
      end

      def create_account(payload)
        account = service.create_account(
          payload: payload
        )
        Success(account)
      end

      def create_contact(payload)
        contact = service.create_contact_for_account(
          payload: payload
        )
        Success(contact)
      end

      def update_account(id, payload)
        account = service.update_account(
          id: id,
          payload: payload
        )
        Success(account)
      end

      def update_contact(id, payload)
        contact = service.update_contact(
          id: id,
          payload: payload
        )
        Success(contact)
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
