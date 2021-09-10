# frozen_string_literal: true

# Class for recording the outcome of publishing
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  field :processed_at, type: DateTime, default: nil
  field :event_name_identifier, type: String, default: ""
  field :data, type: Hash

  aasm do
    state :draft, initial: true
    state :publishing
    state :successful
    state :failure

    event :process do
      transitions from: :draft, to: :processing
    end

    event :complete do
      transitions from: :publishing, to: :successful
    end
  end
end
