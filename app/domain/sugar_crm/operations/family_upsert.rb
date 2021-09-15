# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require_relative '../../sugar_crm/services/connection'

module SugarCRM
  module Operations
    # Passing family payload onto CRM Gateway
    class FamilyUpsert
      include Dry::Monads[:result, :do, :try]

      def call(payload:)
        existing_account = yield find_existing_account(
          hbx_id: payload[:primary_person_hbx_id]
        )
        contacts = yield find_contacts_by_account(existing_account)
        results = payload[:family_members].map do |family_member|
          matched_contact = match_family_member_to_contact(family_member: family_member, contacts: contacts)
          if matched_contact.success?
            update_existing_contact(id: matched_contact.value!['id'], params: family_member)
          else
            @account ||= find_existing_account(hbx_id: payload['hbx_id'])
            create_contact(account_id: @account, params: family_member)
          end
        end
        if failing_result == results.detect(&:failure?)
          Failure(failing_result.failure)
        else
          Success('Successful family update')
        end
      end

      def find_existing_account(hbx_id:)
        if existing_account == service.find_account_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure('No account found')
        end
      end

      def find_contacts_by_account(account_id)
        contacts = service.find_contacts_by_account(account_id)

        Success(contacts['records'])
        # rescue =>
      end

      def match_family_member_to_contact(family_member:, contacts:)
        matched_contact = contacts.find do |contact|
          contact['hbxid_c'] == family_member[:hbx_id]
        end
        if matched_contact
          Success(matched_contact)
        else
          Failure('No matched contact found')
        end
      end

      def update_existing_contact(id:, params:)
        result = service.update_contact(
          id: id,
          first_name: params[:person][:person_name][:first_name],
          last_name: params[:last_name]
        )
        if result
          Success(result)
        else
          Failure("Couldn't update contact")
        end
      end

      def create_contact(account_id:, params:)
        result = service.create_contact_for_account(
          account_id: account_id,
          hbx_id: params[:hbx_id],
          first_name: params[:person][:person_name][:first_name],
          last_name: params[:last_name]
        )
        if result
          Success(result)
        else
          Failure("Couldn't create a contact")
        end
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
