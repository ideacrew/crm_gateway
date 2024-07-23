# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module SugarCRM
    # This class is responsible for fetching an account from SugarCRM and transforming it into a domain entity.
    class FetchAccount
      include Dry::Monads[:do, :result]

      # Calls the operations to validate input, fetch account from SugarCRM, parse, transform, and create an account entity.
      # @param params [Hash] The parameters to fetch an account, must include :account_hbx_id.
      # @return [Dry::Monads::Result] Success or Failure monad with the account entity or error message.
      def call(params)
        account_hbx_id            = yield validate(params)
        account_params            = yield sugar_account(account_hbx_id)
        parsed_account_params     = yield parse_account_params(account_params)
        tranformed_account_params = yield transform_account(parsed_account_params)
        account                   = yield account_entity(tranformed_account_params)

        Success(account)
      end

      private

      # Validates the input parameters.
      # @param params [Hash] The parameters to validate.
      # @return [Dry::Monads::Result] Success monad with the account_hbx_id or Failure monad with error message.
      def validate(params)
        account_hbx_id = params[:account_hbx_id]

        if account_hbx_id.present? && account_hbx_id.is_a?(String)
          Success(account_hbx_id)
        else
          Failure("Account HBX ID is required and must be a string. Received: #{account_hbx_id}")
        end
      end

      # Calls SugarCRM to fetch the account.
      # @param hbx_id [String] The HBX ID of the account to fetch.
      # @return [Dry::Monads::Result] Success monad with account parameters or Failure monad with error message.
      def sugar_account(hbx_id)
        Success(::SugarCRM::Services::Connection.new.fetch_account_including_contacts_by_hbx_id(hbx_id))
      rescue StandardError => e
        Failure("Unable to fetch account from SugarCRM: #{e.message} for account: #{hbx_id}")
      end

      # Parses the account parameters.
      # @param account_params [Hash] The raw account parameters from SugarCRM.
      # @return [Dry::Monads::Result] Success monad with parsed account parameters or Failure monad with error message.
      def parse_account_params(account_params)
        Success(JSON.parse(account_params.to_json, symbolize_names: true))
      rescue JSON::ParserError => e
        Failure("Unable to parse account params from SugarCRM: #{e.message} for account: #{account_params}")
      end

      # Transforms the parsed account parameters into a domain entity.
      # @param parsed_account_params [Hash] The parsed account parameters.
      # @return [Dry::Monads::Result] Success monad with transformed account parameters.
      def transform_account(parsed_account_params)
        ::AcaEntities::Crm::Transformers::SugarAccountTo::Account.new.call(parsed_account_params)
      end

      # Creates an account entity.
      # @param account_params [Hash] The transformed account parameters.
      # @return [Dry::Monads::Result] Success monad with the account entity.
      def account_entity(account_params)
        ::AcaEntities::Crm::Operations::CreateAccount.new.call(account_params)
      end
    end
  end
end
