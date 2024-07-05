# frozen_string_literal: true

module Transmittable
  # Represents a single workflow event instance for transmission to an external service. It encapsulates
  # all necessary details for the transaction including its associated transmissions, process status, and
  # any errors that might have occurred during the transaction's lifecycle.
  class Transaction
    include Mongoid::Document
    include Mongoid::Timestamps

    # Associations

    # @!attribute [rw] transactable
    #   @return [Mongoid::Document] Polymorphic association to the object this transaction belongs to.
    belongs_to :transactable, polymorphic: true, index: true

    # @!attribute [rw] transactions_transmissions
    #   @return [Array<Transmittable::TransactionsTransmissions>] the transmissions associated with this transaction.
    has_many :transactions_transmissions, class_name: 'Transmittable::TransactionsTransmissions', dependent: :destroy

    # @!attribute [rw] process_status
    #   @return [Transmittable::ProcessStatus] the process status associated with this transaction.
    has_one :process_status, as: :statusable, class_name: 'Transmittable::ProcessStatus', dependent: :destroy

    # @!attribute [rw] transmittable_errors
    #   @return [Array<Transmittable::Error>] the errors associated with this transaction.
    has_many :transmittable_errors, as: :errorable, class_name: 'Transmittable::Error', dependent: :destroy

    # Nested attributes
    accepts_nested_attributes_for :process_status
    accepts_nested_attributes_for :transmittable_errors

    # Fields

    # @!attribute [rw] key
    #   @return [Symbol] A unique key identifying the transaction.
    field :key, type: Symbol

    # @!attribute [rw] title
    #   @return [String] The title of the transaction.
    field :title, type: String

    # @!attribute [rw] description
    #   @return [String] A description of the transaction.
    field :description, type: String

    # @!attribute [rw] started_at
    #   @return [DateTime] The timestamp when the transaction started.
    field :started_at, type: DateTime

    # @!attribute [rw] ended_at
    #   @return [DateTime] The timestamp when the transaction ended.
    field :ended_at, type: DateTime

    # @!attribute [rw] transaction_id
    #   @return [String] A unique identifier for the transaction.
    field :transaction_id, type: String

    # @!attribute [rw] json_payload
    #   @return [Hash] The JSON payload associated with the transaction.
    field :json_payload, type: Hash

    # @!attribute [rw] xml_payload
    #   @return [String] The XML payload associated with the transaction.
    field :xml_payload, type: String

    # Indexes
    index({ key: 1 })
    index({ created_at: 1 })

    # Instance Methods

    # Checks if the transaction has succeeded based on its process status.
    # @return [Boolean] true if the transaction's latest state is :succeeded, false otherwise.
    def succeeded?
      process_status&.latest_state == :succeeded
    end

    # Generates a string of error messages from associated transmittable_errors.
    # @return [String] concatenated error messages separated by semicolons.
    def error_messages
      return [] unless errors

      transmittable_errors&.map {|error| "#{error.key}: #{error.message}"}&.join(";")
    end

    # Retrieves the transmissions associated with this transaction.
    # @return [Mongoid::Criteria] A criteria object representing the transmissions associated with this transaction.
    def transmissions
      ::Transmittable::Transmission.where(
        :id.in => transactions_transmissions.pluck(:transmission_id)
      )
    end
  end
end
