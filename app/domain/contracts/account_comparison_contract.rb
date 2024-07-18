# frozen_string_literal: true

require 'types'

module Contracts
  # A contract for validating account comparison parameters.
  # This contract uses Dry::Validation to enforce input validation rules.
  #
  # @example Validate input data
  #   contract = Contracts::AccountComparisonContract.new
  #   result = contract.call(action: :create, account_hbx_id: "12345")
  #   result.success? # => true or false based on validation
  #
  class AccountComparisonContract < ::Dry::Validation::Contract
    params do
      # Validates the presence of an action and that it is one of the specified symbols.
      #
      # @return [Symbol] Required action symbol, must be filled and one of the specified values.
      required(:action).filled(Types::CompareActionKind)

      # Validates that the account_hbx_id, if provided, is a string.
      #
      # @return [String, nil] Optional account HBX ID, can be nil or a string.
      optional(:account_hbx_id).maybe(:string)

      # Validates that the account_action, if provided, is a symbol.
      #
      # @return [Symbol, nil] Optional account action symbol, can be nil or a symbol.
      optional(:account_action).maybe(Types::AccountOrContactActionKind)

      # Validates an optional array of contacts, ensuring each contact is a hash with required :hbx_id and :action keys.
      #
      # @return [Array<Hash>] Optional array of contacts, each contact must be a hash with required :hbx_id and :action keys.
      optional(:contacts).array(:hash) do
        required(:hbx_id).filled(:string)
        required(:action).filled(Types::AccountOrContactActionKind)
      end
    end
  end
end
