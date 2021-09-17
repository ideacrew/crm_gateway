# frozen_string_literal: true

# Class for recording the outcome of publishing
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CableReady::Broadcaster

  field :processed_at, type: DateTime, default: nil
  field :failed_at, type: DateTime, default: nil
  field :completed_at, type: DateTime, default: nil
  field :event_name_identifier, type: String, default: ''
  field :data, type: Hash, default: {}
  field :aasm_state, type: String
  field :account_id, type: String
  field :contact_id, type: String
  field :error_message, type: String
  field :error_backtrace, type: Array, default: []
  field :error, type: String
  field :archived, type: Boolean, default: false

  aasm do
    state :received, initial: true
    state :processing
    state :successful
    state :failure

    event :process do
      transitions from: :received, to: :processing
    end

    event :fail do
      transitions from: :processing, to: :failure
    end

    event :complete do
      transitions from: :processing, to: :successful
    end

    event :fail do
      transitions from: [:processing, :received], to: :failure
    end

    event :retry do
      transitions from: :failure, to: :received
    end
  end

  def archive
    self.error = ''
    self.error_message = ''
    self.save!
  end

  def processed?
    processed_at.present?
  end

  def latest_timestamp
    if self.aasm_state == 'processing'
      return self.processed_at
    elsif self.aasm_state == 'successful'
      return self.completed_at
    else self.aasm_state == 'received'
      return self.created_at
    end
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

  after_update do
    update_morph
  end

  def update_morph
    row_html = ApplicationController.render(
      partial: "events/event_row",
      locals: { event: self }
    )
    puts("Beginning row morph for event #{id}")

    cable_ready["events"].morph(
      selector: "#event-row-#{id}",
      html: row_html
    )

    cable_ready.broadcast

    show_html = ApplicationController.render(
      partial: "events/event",
      locals: { event: self }
    )

    cable_ready["events"].morph(
      selector: "#event-#{id}",
      html: show_html
    )

    cable_ready.broadcast
  end

  after_create do
    create_morph
  end

  def create_morph
    row_html = ApplicationController.render(
      partial: "events/event_row",
      locals: { event: self }
    )

    cable_ready['events'].prepend(
      selector: 'table tbody',
      html: row_html
    )

    cable_ready.broadcast
  end
end
