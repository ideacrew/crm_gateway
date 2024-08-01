# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module SugarCRM
    # Operation is responsible for updating the SugarCRM account and contacts based on the provided parameters.
    class Update
      include Dry::Monads[:do, :result]

      # { comparison: comparison, request_objects: request_objects }
      # Updates the SugarCRM account and contacts based on the provided parameters.
      #
      # @param params [Hash] The parameters required for the update process.
      # @option params [Object] :comparison The comparison object.
      # @option params [Array<Object>] :request_objects The request objects.
      # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure] The result of the update process.
      def call(params)
        account_entity, comparison  = yield validate(params)
        @sugar_account_id           = yield find_sugar_account_id
        account_result              = yield update_sugar_for_account(account_entity, comparison)
        contact_results             = yield update_sugar_for_contacts(account_entity, comparison)
        tranformed_comparion        = yield transform(account_result, contact_results, comparison)
        updated_comparison          = yield create_comparison(tranformed_comparion)

        Success(updated_comparison)
      end

      private

      # Validates the provided parameters and extracts the comparison and account entities.
      #
      # @param params [Hash] The parameters required for validation.
      # @option params [Entities::AccountComparison] :comparison The comparison object.
      # @option params [Hash] :request_objects The request objects containing the subject.
      # @option params [AcaEntities::Crm::Account] :subject The subject containing the outbound account entity.
      # @return [Dry::Monads::Result::Success<Array>] If validation is successful, returns a success result with an array containing the account and comparison.
      # @return [Dry::Monads::Result::Failure<String>] If validation fails, returns a failure result with an error message.
      def validate(params)
        comparison = params[:comparison]
        account = params.dig(:request_objects, :subject)&.outbound_account_entity

        if comparison.is_a?(Entities::AccountComparison) && account.is_a?(AcaEntities::Crm::Account)
          @account_hbx_id = account.hbxid_c
          @connection = ::SugarCRM::Services::Connection.new
          Success([account, comparison])
        else
          Failure('Invalid comparison or request objects.')
        end
      end

      # Finds the SugarCRM account ID based on the HBX ID.
      #
      # @note The result could be nil, which is valid for new accounts that need to be created in SugarCRM.
      #
      # @return [Dry::Monads::Result::Success<String>, Dry::Monads::Result::Failure<String>]
      #   If successful, returns a success result with the SugarCRM account ID.
      #   If an error occurs, returns a failure result with an error message.
      def find_sugar_account_id
        Success(@connection.fetch_account_by_hbx_id(@account_hbx_id)&.dig('id'))
      rescue StandardError => e
        Failure("CONNECTION ERRORED. Unable to find account with hbx_id: #{@account_hbx_id} in SugarCRM: #{e.message}")
      end

      # Updates the SugarCRM account based on the comparison action.
      #
      # @param account_entity [AcaEntities::Crm::Account] The account entity to be updated or created.
      # @param comparison [Entities::AccountComparison] The comparison object containing the action to be performed.
      # @option comparison [Symbol] :account_action The action to be performed on the account (:create, :update, :noop).
      # @return [Dry::Monads::Result::Success<Hash>, Dry::Monads::Result::Failure<String>]
      #   If successful, returns a success result with a hash containing the response details.
      #   If an error occurs, returns a failure result with an error message.
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

      # Creates an account in SugarCRM.
      #
      # @param account_entity [Object] The account entity object containing account details.
      # @return [Success, Failure] Returns a Success object with response details if the account is created successfully,
      #   otherwise returns a Failure object with an error message.
      def create_account(account_entity)
        response = @connection.create_an_account(payload: account_entity.to_h.deep_symbolize_keys.except(:contacts))
        @sugar_account_id = JSON.parse(response.body)['id']
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

      # Updates an account in SugarCRM.
      #
      # @param account_entity [Object] The account entity object containing account details.
      # @return [Success, Failure] Returns a Success object if the account is updated successfully, otherwise returns a Failure object.
      # @raise [StandardError] Raises an error if the account update fails.
      def update_account(account_entity)
        return Failure("Cannot update Account with hbx_id: #{@account_hbx_id} in SugarCRM without Sugar Account ID") unless @sugar_account_id

        response = @connection.update_the_account(
          id: @sugar_account_id,
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

      # Updates SugarCRM for contacts associated with the given account entity.
      #
      # @param account_entity [Object] The account entity object containing account and contact details.
      # @param comparison [Object] The comparison object containing the current state of contacts.
      # @return [Success, Failure] Returns a Success object with the results of the contact updates.
      # @raise [StandardError] Raises an error if the contact update fails.
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

        Success(contact_results)
      end

      # Creates a contact in SugarCRM.
      #
      # @param contact [Object] The contact object containing contact details.
      # @return [Hash] A hash containing the response code, response body, and response message.
      # @option return [Integer, nil] :response_code The HTTP status code of the response.
      # @option return [Object, nil] :response_body The body of the response.
      # @option return [String] :response_message A message describing the result of the operation.
      # @raise [StandardError] Raises an error if the contact creation fails.
      def create_contact(contact)
        Rails.logger.info { @sugar_account_id }
        unless @sugar_account_id
          return {
            response_code: nil,
            response_body: nil,
            response_message: "Cannot create contact with hbx_id: #{contact.hbxid_c} in SugarCRM without Sugar Account ID"
          }
        end

        response = @connection.create_a_contact(
          payload: contact.to_h.deep_symbolize_keys.merge(
            account_id: @sugar_account_id
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

      # Updates a contact in SugarCRM.
      #
      # @param contact [Object] The contact object containing contact details.
      # @return [Hash] A hash containing the response code, response body, and response message.
      # @option return [Integer, nil] :response_code The HTTP status code of the response.
      # @option return [Object, nil] :response_body The body of the response.
      # @option return [String] :response_message A message describing the result of the operation.
      # @raise [StandardError] Raises an error if the contact update fails.
      def update_contact(contact)
        unless @sugar_account_id
          return {
            response_code: nil,
            response_body: nil,
            response_message: "Cannot update contact with hbx_id: #{contact.hbxid_c} in SugarCRM without Sugar Account ID"
          }
        end

        @contact_id = @connection.find_contact_by_hbx_id(contact.hbxid_c)
        unless @contact_id
          return {
            response_code: nil,
            response_body: nil,
            response_message: "Unable to find contact with hbx_id: #{contact.hbxid_c} in SugarCRM"
          }
        end

        response = @connection.update_the_contact(
          id: @contact_id,
          payload: contact.to_h.deep_symbolize_keys.merge(
            account_id: @sugar_account_id
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

      # Transforms the account and contact results into a comparison info hash.
      #
      # @param account_result [Hash] The result hash containing account response details.
      # @param contact_results [Hash] The result hash containing contact response details.
      # @param comparison [Object] The comparison object containing the initial state of the account and contacts.
      # @return [Success] Returns a Success object with the transformed comparison info.
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

      # Creates a comparison record in the system.
      #
      # @param transformed_comparison [Hash] The transformed comparison hash containing account and contact comparison details.
      # @return [Result] The result of the create operation, typically a Success or Failure object.
      def create_comparison(tranformed_comparion)
        result = ::Operations::AccountComparison::Create.new.call(tranformed_comparion)
        Rails.logger.info { result.success? ? result.value!.inspect : Failure(result.failure) }
        result
      end
    end
  end
end
