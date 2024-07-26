# TODO: CALL SUGARCRM API TO CREATE OR UPDATE ACCOUNT, CONTACTS AND
#       REVIEW THE RESPONSE TO ADD RESPONSE CODE AND MESSAGE TO
#       THE COMPARISON OBJECT.


# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module SugarCRM
    # This class is responsible for updating SugarCRM database.
    # This class creates or updates the account and contacts in SugarCRM.
    class Update
      include Dry::Monads[:do, :result]

      # { comparison: comparison, request_objects: request_objects }
      def call(params)
        account_entity, comparison = yield validate(params)
        account_result = yield update_sugar_for_account(account_entity, comparison)
        contact_results = yield update_sugar_for_contacts(account_entity, comparison)
        tranformed_comparion = yield transform(account_result, contact_results, comparison)
        updated_comparison = yield create_comparison(tranformed_comparion)

        Success(updated_comparison)
      end

      private

      def validate(params)
        comparison = params[:comparison]
        account = params.dig(:request_objects, :subject)&.outbound_account_entity

        if comparison.is_a?(Entities::AccountComparison) && account.is_a?(AcaEntities::Crm::Account)
          @connection = ::SugarCRM::Services::Connection.new
          Success([account, comparison])
        else
          Failure('Invalid comparison or request objects.')
        end
      end

      def update_sugar_for_account(account_entity, comparison)
        case comparison.account_action
        when :create
          create_account(account_entity)
        when :update
          update_account(account_entity)
        when :noop
          Success(
            {
              response_code: nil,
              response_body: nil,
              response_message: "No action needed for account with hbx_id: #{account_entity.hbxid_c}"
            }
          )
        else
          Failure("Unknown action for account with hbx_id: #{account_entity.hbxid_c}")
        end
      end

      def create_account(account_entity)
        response = @connection.create_an_account(payload: account_entity.to_h.deep_symbolize_keys.except(:contacts))

        Success(
          {
            response_code: response.status,
            response_body: response.body,
            response_message: "Account with hbx_id: #{account_entity.hbxid_c} created successfully in SugarCRM"
          }
        )
      rescue StandardError => e
        Failure("Unable to create account with hbx_id: #{account_entity.hbxid_c} in SugarCRM: #{e.message}")
      end

      def update_account(account_entity)
        @account_hbx_id = account_entity.hbxid_c
        @account_id = @connection.find_account_by_hbx_id(@account_hbx_id)
        return Failure("Unable to find account with hbx_id: #{@account_hbx_id} in SugarCRM") unless @account_id

        response = @connection.update_the_account(
          id: @account_id,
          payload: account_entity.to_h.deep_symbolize_keys.except(:contacts)
        )

        Success(
          {
            response_code: response.status,
            response_body: response.body,
            response_message: "Account with hbx_id: #{account_entity.hbxid_c} updated successfully in SugarCRM"
          }
        )
      rescue StandardError => e
        Failure("Unable to update account with hbx_id: #{account_entity.hbxid_c} in SugarCRM: #{e.message}")
      end

      def update_sugar_for_contacts(account_entity, comparison)
        contact_results = account_entity.contacts.inject({}) do |results, contact|
          comparison_contact = comparison.contacts.detect { |c| c.hbx_id == contact.hbxid_c }

          results[contact.hbxid_c] = case comparison_contact&.action
                                     when :create
                                       create_contact(contact)
                                     when :update
                                       update_contact(contact)
                                     when :noop
                                       {
                                         response_code: nil,
                                         response_body: nil,
                                         response_message: "No action needed for contact with hbx_id: #{contact.hbxid_c}"
                                       }
                                     else
                                       {
                                         response_code: nil,
                                         response_body: nil,
                                         response_message: "Unknown action for contact with hbx_id: #{contact.hbxid_c}"
                                       }
                                     end


          results
        end

        Succes(contact_results)
      end

      def create_contact(contact)
        response = @connection.create_a_contact(
          payload: contact.to_h.deep_symbolize_keys.merge(
            account_id: @account_id
          )
        )

        msg = if response.status.between?(200, 299)
                "Contact with hbx_id: #{contact.hbxid_c} created successfully in SugarCRM for account with hbx_id: #{@account_hbx_id}"
              else
                "Unable to create contact with hbx_id: #{contact.hbxid_c} in SugarCRM"
              end

        {
          response_code: response.status,
          response_body: response.body,
          response_message: msg
        }
      rescue StandardError => e
        {
          response_code: nil,
          response_body: nil,
          response_message: "CONNECTION ERRORED. Unable to create contact with hbx_id: #{contact.hbxid_c} in SugarCRM: #{e.message}"
        }
      end

      def update_contact(contact)
        @contact_id = @connection.find_contact_by_hbx_id(contact.hbxid_c)
        return "Unable to find contact with hbx_id: #{contact.hbxid_c} in SugarCRM" unless @contact_id

        response = @connection.update_the_contact(
          id: @contact_id,
          payload: contact.to_h.deep_symbolize_keys.merge(
            account_id: @account_id
          )
        )

        msg = if response.status.between?(200, 299)
                "Contact with hbx_id: #{contact.hbxid_c} updated successfully in SugarCRM for account with hbx_id: #{@account_hbx_id}"
              else
                "Unable to update contact with hbx_id: #{contact.hbxid_c} in SugarCRM"
              end

        {
          response_code: response.status,
          response_body: response.body,
          response_message: msg
        }
      rescue StandardError => e
        {
          response_code: nil,
          response_body: nil,
          response_message: "CONNECTION ERRORED. Unable to update contact with hbx_id: #{contact.hbxid_c} in SugarCRM: #{e.message}"
        }
      end

      def transform(account_result, contact_results, comparison)
        comparison_info = comparison.to_h

        comparison_info[:response_code] = account_result[:response_code]
        comparison_info[:response_body] = account_result[:response_body]
        comparison_info[:response_message] = account_result[:response_message]

        comparison_info[:contacts].each do |contact|
          contact[:response_code] = contact_results[contact[:hbx_id]][:response_code]
          contact[:response_body] = contact_results[contact[:hbx_id]][:response_body]
          contact[:response_message] = contact_results[contact[:hbx_id]][:response_message]
        end

        Success(comparison_info)
      end

      def create_comparison(tranformed_comparion)
        ::Operations::AccountComparison::Create.new.call(tranformed_comparion)
      end
    end
  end
end
