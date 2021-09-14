# frozen_string_literal: true

# Class for recording the outcome of publishing
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CableReady::Broadcaster

  field :processed_at, type: DateTime, default: nil
  # field :failed_at, type: DateTime, default: nil
  field :completed_at, type: DateTime, default: nil
  field :event_name_identifier, type: String, default: ""
  field :data, type: Hash
  field :aasm_state, type: String
  field :account_id, type: String
  field :contact_id, type: String
  field :error_message, type: String

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
    self.process!
  end

  def complete
    self.completed_at = DateTime.now
    self.complete!
  end

  # def failure
  #   self.failed_at = DateTime.now
  #   self.failure!
  # end

  def morph
    html = ApplicationController.render(
      partial: "events/event_row",
      locals: { event: self }
    )
    puts("Beginning row morph for event #{id}")

    cable_ready["events"].morph(
      selector: "#event-#{id}",
      html: html
    )

    cable_ready.broadcast
  end
end
