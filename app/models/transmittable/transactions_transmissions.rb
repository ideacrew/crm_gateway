# frozen_string_literal: true

module Transmittable
  # Represents the join model between {Transmission} and {Transaction}. It is used to associate
  # a {Transmission} with a {Transaction}, typically during the enqueue process.
  #
  # @!attribute [rw] transmission
  #   @return [Transmittable::Transmission] the transmission part of the association.
  #
  # @!attribute [rw] transaction
  #   @return [Transmittable::Transaction] the transaction part of the association.
  class TransactionsTransmissions
    include Mongoid::Document
    include Mongoid::Timestamps

    # Associations

    # Establishes a belongs_to association to {Transmission}.
    # @!parse belongs_to :transmission, class_name: 'Transmittable::Transmission', index: true
    belongs_to :transmission, class_name: 'Transmittable::Transmission', index: true

    # Establishes a belongs_to association to {Transaction}.
    # @!parse belongs_to :transaction, class_name: 'Transmittable::Transaction', index: true
    belongs_to :transaction, class_name: 'Transmittable::Transaction', index: true
  end
end
