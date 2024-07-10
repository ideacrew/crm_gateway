# frozen_string_literal: true

module Transmittable
  # A concern that, when included, adds a one-to-many association from the including class to the
  # Transmittable::Transaction class. This allows instances of the including class to have multiple
  # associated transactions.
  #
  # @!attribute [rw] transactions
  #   @return [Array<Transmittable::Transaction>] the transactions associated with the transactable object.
  module Subject
    extend ActiveSupport::Concern

    included do
      # Establishes a one-to-many association with Transmittable::Transaction.
      # Transactions are destroyed if the parent object is destroyed.
      has_many :transactions, as: :transactable, class_name: '::Transmittable::Transaction', dependent: :destroy
    end
  end
end
