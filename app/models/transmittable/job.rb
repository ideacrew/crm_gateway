# frozen_string_literal: true

module Transmittable
  # Represents a job that can have multiple transmissions and a single process status. Jobs are uniquely
  # identified by a message_id and can contain various metadata such as title, description, and timing information.
  class Job
    include Mongoid::Document
    include Mongoid::Timestamps

    # Associations
    # @!attribute [rw] transmissions
    #   @return [Array<Transmittable::Transmission>] the transmissions associated with this job.
    has_many :transmissions, class_name: 'Transmittable::Transmission', dependent: :destroy

    # @!attribute [rw] process_status
    #   @return [Transmittable::ProcessStatus] the process status associated with this job.
    has_one :process_status, as: :statusable, class_name: 'Transmittable::ProcessStatus', dependent: :destroy

    # @!attribute [rw] transmittable_errors
    #   @return [Array<Transmittable::Error>] the errors associated with this job.
    has_many :transmittable_errors, as: :errorable, class_name: 'Transmittable::Error', dependent: :destroy

    # Nested attributes
    accepts_nested_attributes_for :process_status
    accepts_nested_attributes_for :transmittable_errors

    # Fields
    field :job_id, type: String
    field :saga_id, type: String
    field :key, type: String
    field :title, type: String
    field :description, type: String
    field :publish_on, type: Date
    field :expire_on, type: DateTime
    field :started_at, type: DateTime
    field :ended_at, type: DateTime
    field :time_to_live, type: Integer
    field :allow_list, type: Array
    field :deny_list, type: Array
    field :message_id, type: String

    # Validations
    validates :message_id, uniqueness: true

    # Scopes
    # @!method latest
    #   @return [Mongoid::Criteria] a criteria object to find the most recently created jobs.
    scope :latest, -> { order(created_at: :desc) }

    # Callbacks
    before_create :generate_message_id

    # Instance Methods

    # Generates a string of error messages from associated transmittable_errors.
    # @return [String] concatenated error messages separated by semicolons.
    def error_messages
      return [] unless errors

      transmittable_errors&.map { |error| "#{error.key}: #{error.message}" }&.join(';')
    end

    private

    # Generates a unique message_id for the job before creation.
    # @note This method sets the message_id field to a new UUID if it is not already present.
    def generate_message_id
      return if message_id.present?

      loop do
        @generated_message_id = SecureRandom.uuid

        break if Transmittable::Job.where(message_id: @generated_message_id).blank?
      end

      self[:message_id] = @generated_message_id
    end
  end
end
