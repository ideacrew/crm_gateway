# frozen_string_literal: true

# Class for recording the outcome of publishing
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  field :processed_at, type: DateTime, default: nil
  field :event_name_identifier, type: String, default: ""
  field :data, type: Hash
  field :aasm_state, type: String
  field :account_id, type: String
  field :contact_id, type: String
  field :error_message, type: String
  field :processing_at, type: DateTime
  field :completed_at, type: DateTime

  aasm do
    state :received, initial: true
    state :processing
    state :successful
    state :failure

    event :process do
      transitions from: :received, to: :processing
    end

    # event :fail do
    #   transitions from: :processing, to: :failure
    # end

    event :complete do
      transitions from: :processing, to: :successful
    end
  end

  def processed?
    processed_at.present?
  end

  def process
    self.processed_at = DateTime.now
  end
end
