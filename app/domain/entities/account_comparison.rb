# frozen_string_literal: true

require 'types'

module Entities
  # Represents a comparison of account information.
  #
  # @!attribute [r] action
  #   The primary action to be performed with this account comparison.
  #   @return [Symbol] the action symbol, cannot be omitted.
  #
  # @!attribute [r] account_hbx_id
  #   The Health Benefit Exchange Identifier for the account, if applicable.
  #   @return [String, nil] the HBX ID of the account, can be omitted.
  #
  # @!attribute [r] account_action
  #   An optional action to be performed specifically on the account.
  #   @return [Symbol, nil] the action symbol for the account, can be omitted.
  #
  # @!attribute [r] contacts
  #   A list of contacts associated with the account, each with its own action.
  #   @return [Array<Hash>] the array of contacts, each contact hash includes a mandatory :hbx_id and :action, can be omitted.
  #
  class AccountComparison < ::Dry::Struct
    attribute :action, Types::CompareActionKind.meta(omittable: false)
    attribute :account_hbx_id, Types::String.optional.meta(omittable: true)
    attribute :account_action, Types::AccountOrContactActionKind.optional.meta(omittable: true)
    attribute :contacts, Types::Array.of(::Entities::ContactComparison).optional.meta(omittable: true)
  end
end
