# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Operations
  module AccountComparison
    # Creates an AccountComparison entity after validating the input parameters.
    #
    # This operation uses Dry::Monads for functional programming paradigms, specifically
    # utilizing the Do notation for chaining operations and handling success or failure cases.
    #
    # @example
    #   result = Operations::AccountComparison::Create.new.call(action: :create, account_hbx_id: "12345")
    #   result.success? # => true for successful creation, false for failure
    #
    class Create
      include Dry::Monads[:do, :result]

      # Processes the input parameters to create an AccountComparison entity.
      #
      # @param params [Hash] The input parameters for creating an AccountComparison.
      # @option params [Symbol] :action The action to be performed.
      # @option params [String] :account_hbx_id (optional) The HBX ID of the account.
      # @option params [Symbol] :account_action (optional) The specific action for the account.
      # @option params [Array<Hash>] :contacts (optional) The contacts associated with the account.
      #
      # @return [Dry::Monads::Result] A success or failure monadic object encapsulating the AccountComparison entity or error messages.
      def call(params)
        values = yield validate_params(params)
        family = yield create_account(values)

        Success(family)
      end

      private

      # Validates the input parameters against the AccountComparisonContract.
      #
      # @param params [Hash] The input parameters to be validated.
      # @return [Dry::Monads::Result] A success or failure monadic object encapsulating the validated parameters or error messages.
      def validate_params(params)
        result = ::Contracts::AccountComparisonContract.new.call(params)

        if result.success?
          Success(result.to_h)
        else
          Failure(result.errors.to_h)
        end
      end

      # Creates an AccountComparison entity with the validated parameters.
      #
      # @param values [Hash] The validated parameters.
      # @return [Dry::Monads::Result] A success monadic object encapsulating the AccountComparison entity.
      def create_account(values)
        Success(::Entities::AccountComparison.new(values))
      end
    end
  end
end
