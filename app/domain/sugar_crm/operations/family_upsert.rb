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
        @payload = payload.deep_symbolize_keys
        existing_account = find_existing_account(
          hbx_id: primary_person[:hbx_id]
        )
        if existing_account.success?
          update_account
        else
          existing_account = create_account
        end
        return Failure(existing_account.failure) if existing_account.failure?
        results = @payload[:family_members].map do |family_member|
          family_member_hbx_id = family_member[:hbx_id]
          existing_contact = service.find_contact_by_hbx_id(family_member_hbx_id)
          if existing_contact
            update_existing_contact(id: existing_contact, account_id: existing_account.value!, params: family_member)
          else
            create_contact(account_id: existing_account.value!, params: family_member)
          end
        end
        if failing_result = results.detect(&:failure?)
          Failure(failing_result.failure)
        else
          Success("Successful family update")
        end
      rescue Faraday::ConnectionFailed => e
        Failure(error: "couldn't connect to host", error_message: e.message, error_backtrace: e.backtrace)
      rescue StandardError => e
        Failure(error: 'Unknown error', error_message: e.message, error_backtrace: e.backtrace)
      end

      def mobile_phone_finder(payload)
        phone_number = payload.compact.detect { |number| number[:kind] == 'mobile' } ||
                       payload.compact.detect { |number| number[:kind] == 'home' } ||
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

      def payload_to_account_params
        {
          hbxid_c: primary_person[:hbx_id],
          name: primary_person.dig(:person, :person_name, :full_name),
          email1: primary_person.dig(:person, :emails, 0, :address),
          billing_address_street: primary_person.dig(:person, :addresses, 0, :address_1),
          billing_address_street_2: primary_person.dig(:person, :addresses, 0, :address_2),
          billing_address_street_3: primary_person.dig(:person, :addresses, 0, :address_3),
          billing_address_street_4: primary_person.dig(:person, :addresses, 0, :address_4),
          billing_address_city: primary_person.dig(:person, :addresses, 0, :city),
          billing_address_postalcode: primary_person.dig(:person, :addresses, 0, :zip),
          billing_address_state: primary_person.dig(:person, :addresses, 0, :state),
          phone_office: mobile_phone_finder(primary_person.dig(:person, :phones)),
          rawssn_c: primary_person[:person][:person_demographics][:ssn],
          raw_ssn_c: primary_person[:person][:person_demographics][:ssn],
          dob_c: convert_dob_to_string(primary_person.dig(:person, :person_demographics, :dob))
          enroll_account_link_c: primary_person[:person][:external_person_link]
        }
      end

      def payload_to_contact_params(payload)
        {
          hbxid_c: payload[:hbx_id],
          first_name: payload.dig(:person, :person_name, :first_name),
          last_name: payload.dig(:person, :person_name, :last_name),
          phone_mobile: mobile_phone_finder(payload.dig(:person, :phones)),
          email1: payload.dig(:person, :emails, 0, :address),
          birthdate: convert_dob_to_string(payload.dig(:person, :person_demographics, :dob)),
          relationship_c: person_relationship_finder(payload[:hbx_id])
        }
      end

      def primary_person
        @payload[:family_members].detect do |family_member|
          family_member[:is_primary_applicant] == true
        end
      end

      def convert_dob_to_string(dob)
        date = Date.parse(dob.to_s)
        date.strftime("%Y-%m-%d")
      end

      def person_relationship_finder(hbx_id_to_match)
        return "Self" if hbx_id_to_match == primary_person[:hbx_id]

        matched_relative = primary_person[:person][:person_relationships].detect do |relative_hash|
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

      def update_existing_contact(id:, account_id:, params:)
        result = service.update_contact(
          id: id,
          payload: payload_to_contact_params(params).merge(account_id: account_id)
        )
        if result
          Success(result)
        else
          Failure("Couldn't update contact")
        end
      end

      def create_contact(account_id:, params:)
        contact = service.create_contact_for_account(
          payload: payload_to_contact_params(params).merge(account_id: account_id)
        )
        Failure("Couldn't create contact") unless contact
        Success(contact)
      end

      def update_account
        account = service.update_account(
          hbx_id: primary_person[:hbx_id],
          payload: payload_to_account_params
        )
        Failure("Couldn't update account") unless account
        Success(account)
      end

      def create_account
        account = service.create_account(payload: payload_to_account_params)
        Failure("Couldn't create account") unless account
        Success(account['id'])
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
