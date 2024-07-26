# frozen_string_literal: true

require 'types'

module Entities
  # Represents a comparison of account information.
  #
  class AccountComparison < ::Dry::Struct

    # Constant that defines action kinds which do not result in any updates or changes.
    # These actions are considered inactive as they do not require any processing.
    #
    # @return [Array<Symbol>] An array of symbols representing inactive action kinds.
    INACTIVE_ACTION_KINDS = %i[noop stale].freeze

    # @!attribute [r] action
    #   The primary action to be performed with this account comparison.
    #   @return [Symbol] the action symbol, cannot be omitted.
    #
    attribute :action, Types::CompareActionKind.meta(omittable: false)

    # @!attribute [r] account_hbx_id
    #   The Health Benefit Exchange Identifier for the account, if applicable.
    #   @return [String, nil] the HBX ID of the account, can be omitted.
    #
    attribute :account_hbx_id, Types::String.optional.meta(omittable: true)

    # @!attribute [r] account_action
    #   An optional action to be performed specifically on the account.
    #   @return [Symbol, nil] the action symbol for the account, can be omitted.
    #
    attribute :account_action, Types::AccountOrContactActionKind.optional.meta(omittable: true)

    # @!attribute [r] contacts
    #   A list of contacts associated with the account, each with its own action.
    #   @return [Array<Hash>] the array of contacts, each contact hash includes a mandatory :hbx_id and :action, can be omitted.
    #
    attribute :contacts, Types::Array.of(::Entities::ContactComparison).optional.meta(omittable: true)

    # Attributes related to the response received from the SugarCRM update operation.
    #
    # @!attribute [r] response_code
    #   The result code from the SugarCRM update operation for the account.
    #   @return [String, nil] the result code from the SugarCRM update, can be omitted.
    #
    attribute :response_code, Types::String.optional.meta(omittable: true)

    # @!attribute [r] response_message
    #   The result message from the SugarCRM update operation for the account.
    #   @return [String, nil] the result message from the SugarCRM update, can be omitted.
    #
    attribute :response_message, Types::String.optional.meta(omittable: true)

    # @!attribute [r] response_body
    #   The result message from the SugarCRM update operation for the account.
    #   @return [String, nil] the result message from the SugarCRM update, can be omitted.
    #
    attribute :response_body, Types::String.optional.meta(omittable: true)

    # Checks if the current action is either a no-operation (:noop) or indicates the account is stale (:stale).
    #
    # @return [Boolean] True if the action is either :noop or :stale, false otherwise.
    def noop_or_stale?
      INACTIVE_ACTION_KINDS.include?(action)
    end
  end
end
