# frozen_string_literal: true

require 'types'

module Entities
  # Represents a Contact entity with specific attributes.
  # This class is used to model the data structure for a contact.
  #
  # @example Creating a new Contact instance
  #   contact = Entities::Contact.new(hbx_id: "12345", action: :create)
  #
  class ContactComparison < Dry::Struct
    # @!attribute [r] hbx_id
    #   @return [String] The Health Benefit Exchange Identifier for the contact
    attribute :hbx_id, Types::String.meta(omittable: false)

    # @!attribute [r] action
    #   @return [Symbol] The action to be performed on the contact (:create, :update, etc.)
    attribute :action, Types::AccountOrContactActionKind.meta(omittable: false)
  end
end
