# frozen_string_literal: true

module Transmittable
  # Represents a specific state within a process, tracking events, messages, and timing information.
  class ProcessState
    include Mongoid::Document
    include Mongoid::Timestamps

    # Associations
    # @!attribute [rw] process_status
    #   @return [Transmittable::ProcessStatus] the process status this state is part of.
    embedded_in :process_status, class_name: 'Transmittable::ProcessStatus'

    # Fields
    # @!attribute [rw] event
    #   @return [String] the name of the event that triggered this state.
    field :event, type: String

    # @!attribute [rw] message
    #   @return [String] a descriptive message about this state.
    field :message, type: String

    # @!attribute [rw] state_key
    #   @return [Symbol] a unique key identifying this state.
    field :state_key, type: Symbol

    # @!attribute [rw] started_at
    #   @return [DateTime] the timestamp when this state was entered.
    field :started_at, type: DateTime

    # @!attribute [rw] ended_at
    #   @return [DateTime] the timestamp when this state was exited.
    field :ended_at, type: DateTime

    # @!attribute [rw] seconds_in_state
    #   @return [Integer] the total number of seconds spent in this state.
    field :seconds_in_state, type: Integer
  end
end
