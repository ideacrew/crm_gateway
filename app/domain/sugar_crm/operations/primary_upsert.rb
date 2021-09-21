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
        existing_account = response_call do
           find_existing_account(hbx_id: hbx_id)
        end
        results = [find_existing_account: existing_account]

        if existing_account.success?
          account_id = extract_first_record_id(existing_account.value!)
          updated_account = response_call { update_account(account_id, payload_to_account_params(payload)) }
          results += [update_account: updated_account]
        else
          created_account = response_call { create_account(payload_to_account_params(payload)) }
          account_id = extract_record_id(created_account.value!) if created_account.success?

          results += [create_account: created_account]
        end

        if account_id
          existing_contact = find_existing_contact(hbx_id: hbx_id)
          results += [find_existing_contact: existing_contact]
          if existing_contact.success?
            id = extract_first_record_id(existing_contact.value!)
            updated_contact = response_call { update_contact(id, account_id, payload_to_contact_params(payload)) }
            results += [update_contact: updated_contact]
          else 
            created_contact = response_call { create_contact(account_id, payload_to_contact_params(payload)) }
            results += [create_contact: created_contact]
          end
          if (updated_account&.success? || created_account&.success?) && (updated_contact&.success? || created_contact&.success?)
            Success(results)
          else
            Failure(results)
          end
        else
          Failure(results)
        end
      end

      def response_call
        yield
      rescue Faraday::ConnectionFailed => e
        Failure(e)
      rescue StandardError => e
        Failure(e)
      end

      def payload_to_contact_params(payload)
        {
          enroll_account_link_c: payload[:external_person_link],
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
          enroll_account_link_c: payload[:external_person_link],
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
        response = service.filter_accounts([hbxid_c: hbx_id])
        if response.parsed['records'].empty?
          Failure(response)
        else
          Success(response)
        end
      end

      def find_existing_contact(hbx_id:)
        response = service.filter_contacts([hbxid_c: hbx_id])
        if response.parsed['records'].empty?
          Failure(response)
        else
          Success(response)
        end
      end

      def extract_first_record_id(response)
        pp response.parsed
        response.parsed.dig('records', 0, 'id')
      end

      def extract_record_id(response)
        response.parsed['id']
      end

      def create_account(payload)
        response = service.create_account(payload: payload)
        if response.status == 200
          Success(response)
        else
          Failure(response)
        end
      end

      def create_contact(account_id, payload)
        response = service.create_contact(payload: payload.merge(account_id: account_id))
        if response.status == 200
          Success(response)
        else
          Failure(response)
        end
      end

      def update_account(id, payload)
        response = service.update_account(
          id: id,
          payload: payload
        )
        if response.status == 200
          Success(response)
        else
          Failure(response)
        end
      end

      def update_contact(id, account_id, payload)
        response = service.update_contact(
          id: id,
          payload: payload.merge(account_id: account_id)
        )
        if response.status == 200
          Success(response)
        else
          Failure(response)
        end
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
