# frozen_string_literal: true

# Class for recording the outcome of publishing
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CableReady::Broadcaster

  field :processing_at, type: DateTime, default: nil
  field :failure_at, type: DateTime, default: nil
  field :successful_at, type: DateTime, default: nil
  field :event_name_identifier, type: String, default: ''
  field :data, type: Hash, default: {}
  field :aasm_state, type: String
  field :account_id, type: String
  field :contact_id, type: String
  field :error_message, type: String
  field :error_backtrace, type: Array, default: []
  field :error, type: String
  field :archived, type: Boolean, default: false

  scope :archived, ->{ where(archived: true) }

  aasm timestamps: true do
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
      before do
        self.error = nil
        self.error_message = nil
        self.error_backtrace = []
      end

      transitions from: :failure, to: :received
    end
  end

  def archive!
    update!(archived: true)
  end

  def processed?
    processed_at.present?
  end

  def latest_timestamp
    case aasm_state
    when 'received'
      created_at
    when 'processing'
      processing_at
    when 'successful'
      successful_at
    when 'failure'
      failure_at
    else
      updated_at
    end
  end

  after_update do
    archived? ? archive_morph : row_morph
    show_morph
  end

  def archive_morph
    cable_ready['events'].remove(
      selector: "#event-row-#{id}"
    )
    cable_ready.broadcast
  end

  def update_morph
    show_morph
  end

  def row_morph
    row_html = ApplicationController.render(
      partial: "events/row",
      locals: { event: self }
    )

    cable_ready["events"].morph(
      selector: "#event-row-#{id}",
      html: row_html
    )

    cable_ready.broadcast
  end

  def show_morph
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
      partial: "events/row",
      locals: { event: self }
    )

    cable_ready['events'].prepend(
      selector: 'table tbody',
      html: row_html
    )

    cable_ready.broadcast
  end
end
