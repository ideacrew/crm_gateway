# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extends Dry::Types with custom types and logic.
module Types
  include Dry.Types
  include Dry::Logic

  # Enum type for account comparison actions.
  # Allows only specific symbols representing the kind of comparison action.
  #
  # @example
  #   Types::CompareActionKind[:create] # => :create
  #   Types::CompareActionKind[:unknown] # Raises Dry::Types::ConstraintError
  #
  # @type [Dry::Types::Type] Enum type for comparison actions.
  CompareActionKind = Types::Coercible::Symbol.enum(
    :create,
    :create_and_update,
    :noop,
    :stale,
    :update
  )

  # Enum type for contact actions within an account comparison.
  # Allows only specific symbols representing the kind of action to be performed on contacts.
  #
  # @example
  #   Types::ContactActionKind[:update] # => :update
  #   Types::ContactActionKind[:invalid] # Raises Dry::Types::ConstraintError
  #
  # @type [Dry::Types::Type] Enum type for contact actions.
  AccountOrContactActionKind = Types::Coercible::Symbol.enum(:create, :noop, :update)
end
