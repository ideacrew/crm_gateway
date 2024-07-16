# frozen_string_literal: true

module Transmittable
  # Represents the overall status of a transmittable process, tracking its current state,
  # the initial state, and the total elapsed time. It is designed to be polymorphically
  # associated with any model that requires process tracking.
  class ProcessStatus
    include Mongoid::Document
    include Mongoid::Timestamps

    # Associations

    # @!attribute [rw] statusable
    #   @return [Mongoid::Document] Polymorphic association to the object this status belongs to.
    belongs_to :statusable, polymorphic: true, inverse_of: :statusable, index: true

    # @!attribute [rw] process_states
    #   @return [Array<Transmittable::ProcessState>] Embedded documents representing the states this process has gone through.
    embeds_many :process_states, class_name: 'Transmittable::ProcessState'

    # Fields

    # @!attribute [rw] initial_state_key
    #   @return [Symbol] The key of the initial state of the process.
    field :initial_state_key, type: Symbol

    # @!attribute [rw] latest_state
    #   @return [Symbol] The key of the latest state of the process.
    field :latest_state, type: Symbol

    # @!attribute [rw] elapsed_time
    #   @return [Integer] The total elapsed time (in seconds) of the process.
    field :elapsed_time, type: Integer

    # Scopes

    # @!method succeeded(transaction_ids)
    #   @param transaction_ids [Array<String>] The IDs of the transactions to filter by.
    #   @return [Mongoid::Criteria] A criteria object to find processes that have succeeded.
    scope :succeeded, ->(transaction_ids) { where(:latest_state => :succeeded, :statusable_id.in => transaction_ids) }

    # @!method not_succeeded(transaction_ids)
    #   @param transaction_ids [Array<String>] The IDs of the transactions to filter by.
    #   @return [Mongoid::Criteria] A criteria object to find processes that have not succeeded.
    scope :not_succeeded, ->(transaction_ids) { where(:latest_state.nin => [:succeeded], :statusable_id.in => transaction_ids) }
  end
end
