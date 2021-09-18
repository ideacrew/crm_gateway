# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require_relative "../../sugar_crm/services/connection"
require 'date'

module SugarCRM
  module Operations
    # class for creating or updating a family
    class FamilyUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :primary_family_member_hbx_id

      def call(payload:)
        payload = payload.deep_symbolize_keys
        existing_account = find_existing_account(
          hbx_id: payload[:hbx_id]
        )
        @payload = payload
        return Failure(existing_account.failure) if existing_account.failure?
        contacts = yield find_contacts_by_account(existing_account.value!)
        results = payload[:family_members].map do |family_member|
          matched_contact = match_family_member_to_contact(family_member: family_member, contacts: contacts)
          if matched_contact.success?
            update_existing_contact(id: matched_contact.value!['id'], params: family_member)
          else
            create_contact(account_id: existing_account.value!, params: family_member)
          end
        end
        if failing_result = results.detect(&:failure?)
          Failure(failing_result.failure)
        else
          Success("Successful family update")
        end
      rescue StandardError => e
        Failure(e)
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
          name: "#{payload[:person][:person_name][:first_name]} #{payload[:person][:person_name][:last_name]}",
          email1: payload[:emails].first[:address],
          billing_address_street: payload[:addresses].first[:address_1],
          billing_address_street_2: payload[:addresses].first[:address_2],
          billing_address_street_3: payload[:addresses].first[:address_3],
          billing_address_street_4: payload[:addresses].first[:address_4],
          billing_address_city: payload[:addresses].first[:city],
          billing_address_postalcode: payload[:addresses].first[:zip],
          billing_address_state: payload[:addresses].first[:state],
          phone_office: mobile_phone_finder(payload[:phones]),
          rawssn_c: payload[:person][:person_demographics][:ssn]
        }
      end

      def payload_to_contact_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          first_name: payload[:person][:person_name][:first_name],
          last_name: payload[:person][:person_name][:last_name],
          phone_mobile: mobile_phone_finder(payload[:person][:phones]),
          email1: payload[:person][:emails].first[:address],
          birthdate: convert_dob_to_string(payload[:person][:person_demographics][:dob]),
          relationship_c: person_relationship_finder(payload[:hbx_id])
        }
      end

      def convert_dob_to_string(dob)
        date = Date.parse(dob.to_s)
        date.strftime("%Y-%m-%d")
      end

      def person_relationship_finder(hbx_id_to_match)
        @primary_family_member ||= @payload[:family_members].detect { |fm| fm[:is_primary_applicant] == true }
        return "self" if hbx_id_to_match == @primary_family_member[:hbx_id]

        matched_relative = @primary_family_member[:person][:person_relationships].detect do |relative_hash|
          relative_hash[:relative][:hbx_id] == hbx_id_to_match
        end
        Rails.logger.debug { "matched relative #{matched_relative}" }
        matched_relative[:kind].titleize
      end

      def find_existing_account(hbx_id:)
        if existing_account = service.find_account_by_hbx_id(hbx_id)
          Success(existing_account)
        else
          Failure(error: "no account found", error_message: "No account found")
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
          Failure("No matched contact found")
        end
      end

      def update_existing_contact(id:, params:)
        result = service.update_contact(id: id, payload: params)
        if result
          Success(result)
        else
          Failure("Couldn't update contact")
        end
      end

      def create_contact(account_id:, params:)
        contact = service.create_contact_for_account(
          payload: payload_to_contact_params(params).merge('account.id': account_id)
        )
        Failure("Couldn't create contact") unless contact
        Success(contact)
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
