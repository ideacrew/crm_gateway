# frozen_string_literal: true

module Transmittable
  # Represents a single transmission event in the Transmittable system. It is designed to track the
  # progress and status of a transmission, including its associated jobs, transactions, and any errors
  # that may occur during the transmission process.
  class Transmission
    include Mongoid::Document
    include Mongoid::Timestamps

    include GlobalID::Identification

    # @!attribute [rw] job
    #   @return [Transmittable::Job, nil] The job associated with this transmission, if any.
    belongs_to :job, class_name: 'Transmittable::Job', optional: true, index: true

    # Represents a Transmission model that can have many associated TransactionsTransmissions.
    # Each TransactionsTransmissions is automatically destroyed when its parent Transmission is destroyed.
    #
    # @!attribute [rw] transactions_transmissions
    #   @return [Array<Transmittable::TransactionsTransmissions>] the collection of associated TransactionsTransmissions.
    has_many :transactions_transmissions, class_name: 'Transmittable::TransactionsTransmissions', dependent: :destroy

    # Establishes a one-to-one association with a ProcessStatus. This ProcessStatus is considered
    # a polymorphic association, allowing for different types of "statusable" objects. When a Transmission
    # object is destroyed, its associated ProcessStatus is also automatically destroyed.
    #
    # @!attribute [rw] process_status
    #   @return [Transmittable::ProcessStatus] the associated ProcessStatus object, polymorphically linked.
    has_one :process_status, as: :statusable, class_name: 'Transmittable::ProcessStatus', dependent: :destroy

    # Establishes a one-to-many association with Transmittable::Error. This association allows a Transmission
    # object to have many associated errors. These errors are considered polymorphic, allowing for different
    # types of "errorable" objects. When a Transmission object is destroyed, all its associated Transmittable::Error
    # objects are also automatically destroyed.
    #
    # @!attribute [rw] transmittable_errors
    #   @return [Array<Transmittable::Error>] the collection of associated Transmittable::Error objects.
    has_many :transmittable_errors, as: :errorable, class_name: 'Transmittable::Error', dependent: :destroy

    # @!attribute [rw] key
    #   @return [Symbol] A unique key identifying the transmission.
    field :key, type: Symbol

    # @!attribute [rw] title
    #   @return [String] The title of the transmission.
    field :title, type: String

    # @!attribute [rw] description
    #   @return [String] A description of the transmission.
    field :description, type: String

    # @!attribute [rw] started_at
    #   @return [DateTime] The timestamp when the transmission started.
    field :started_at, type: DateTime, default: -> { Time.zone.now }

    # @!attribute [rw] ended_at
    #   @return [DateTime] The timestamp when the transmission ended.
    field :ended_at, type: DateTime

    # @!attribute [rw] transmission_id
    #   @return [String] A unique identifier for the transmission.
    field :transmission_id, type: String

    # Indexes
    index({ created_at: 1 })

    # Generates a string of error messages from associated transmittable_errors.
    # @return [String] Concatenated error messages separated by semicolons or an empty string if there are no errors.
    def error_messages
      transmittable_errors.map {|error| "#{error.key}: #{error.message}"}&.join(';')
    end

    # Retrieves the transactions associated with this transmission.
    # @return [Mongoid::Criteria] A criteria object representing the transactions associated with this transmission.
    def transactions
      ::Transmittable::Transaction.in(id: transactions_transmissions.pluck(:transaction_id))
    end
  end
end
