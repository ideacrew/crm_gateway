# frozen_string_literal: true

# Persistence model Family for Alive Status verification
class Family
  include Mongoid::Document
  include Mongoid::Timestamps
  include Transmittable::Subject

  include GlobalID::Identification

  # @!attribute [rw] correlation_id
  #   @return [String] the correlation id
  field :correlation_id, type: String

  # @!attribute [rw] family_hbx_id
  #   @return [String] the family hbx id
  field :family_hbx_id, type: String

  # @!attribute [rw] primary_person_hbx_id
  #   @return [String] the hbx_id of the primary person
  field :primary_person_hbx_id, type: String

  # @!attribute [rw] inbound_raw_headers
  #   @return [String] A hash of headers information sent from the source application to the current application, serialized as a String.
  field :inbound_raw_headers, type: String

  # @!attribute [rw] inbound_raw_payload
  #   @return [String] A hash of the payload/body sent from the source application to the current application, serialized as a String.
  field :inbound_raw_payload, type: String

  # @!attribute [rw] inbound_payload
  #   @return [String] A valid CV family entity hash that is sent from the source application to the current application, serialized as a String.
  field :inbound_payload, type: String

  # @!attribute [rw] outbound_payload
  #   @return [String] A valid Account payload that includes Contacts. Account has a one-to-one mapping with Family, and Contacts has a one-to-one mapping with the Family members, serialized as a String.
  #   @note This payload is not used to send the data to the source application, but to transform the data for comparison. And it is used to create/update accounts and contacts in the SugarCRM.
  field :outbound_payload, type: String

  # @!attribute [rw] job_id
  # @return [String] the job id
  field :job_id, type: String

  # @!attribute [rw] inbound_after_updated_at
  # @return [Time] the updated_at timestamp of the inbound payload
  field :inbound_after_updated_at, type: Time

  # @!attribute [rw] comparison_payload
  # @return [String] the comparison payload has the information about the comparison between the current outbound_payload to the previous outbound_payload.
  # @note This JSON payload also has information about the results that came back from the SugarCRM.
  field :comparison_payload, type: String

  # indexes
  index({ created_at: 1})
  index({ correlation_id: 1 })
  index({ primary_person_hbx_id: 1 })
  index({ family_hbx_id: 1 })
  index({ job_id: 1 })
  index({ family_hbx_id: 1, primary_person_hbx_id: 1 })

  # Scopes
  scope :by_primary_person_hbx_id, ->(primary_person_hbx_id) { where(primary_person_hbx_id: primary_person_hbx_id) }
  scope :by_family_hbx_id, ->(family_hbx_id) { where(family_hbx_id: family_hbx_id) }
  scope :by_correlation_id, ->(correlation_id) { where(correlation_id: correlation_id) }
  scope :by_job_id, ->(job_id) { where(job_id: job_id) }
  scope :by_family_and_primary_person_hbx_id, ->(family_hbx_id, primary_person_hbx_id) { where(family_hbx_id: family_hbx_id, primary_person_hbx_id: primary_person_hbx_id) }

  # @return [Hash, nil] Parses the inbound_payload into a hash if present, memoizes and returns the hash, or nil if inbound_payload is blank.
  def inbound_family_cv_hash
    return if inbound_payload.blank?
    return @inbound_family_cv_hash if defined? @inbound_family_cv_hash

    @inbound_family_cv_hash = JSON.parse(inbound_payload, symbolize_names: true)
  end

  # @return [Object, nil] Creates a Family entity from the inbound_family_cv_hash if present, memoizes and returns the entity, or nil if inbound_family_cv_hash is blank.
  def inbound_family_entity
    return if inbound_family_cv_hash.blank?
    return @inbound_family_entity if defined? @inbound_family_entity

    @inbound_family_entity = ::AcaEntities::Operations::CreateFamily.new.call(
      inbound_family_cv_hash
    ).success
  end

  # @return [Hash, nil] Parses the outbound_payload into a hash if present, memoizes and returns the hash, or nil if outbound_payload is blank.
  def outbound_account_cv_hash
    return if outbound_payload.blank?
    return @outbound_account_cv_hash if defined? @outbound_account_cv_hash

    @outbound_account_cv_hash = JSON.parse(outbound_payload, symbolize_names: true)
  end

  # @return [Object, nil] Creates an Account entity from the outbound_account_cv_hash if present, memoizes and returns the entity, or nil if outbound_account_cv_hash is blank.
  def outbound_account_entity
    return if outbound_account_cv_hash.blank?
    return @outbound_account_entity if defined? @outbound_account_entity

    @outbound_account_entity = ::AcaEntities::Crm::Operations::CreateAccount.new.call(
      outbound_account_cv_hash
    ).success
  end

  # Converts the json comparison_payload into a hash if present, memoizes and returns the hash, or nil if comparison_payload is blank.
  # @return [Hash, nil] the parsed comparison payload as a hash, or nil if comparison_payload is blank
  def comparison_hash
    return if comparison_payload.blank?
    return @comparison_hash if defined? @comparison_hash

    @comparison_hash = JSON.parse(comparison_payload, symbolize_names: true)
  end

  # Creates a comparison entity from the comparison hash, memoizes and returns it, or nil if comparison_hash is blank.
  # @return [Entities::AccountComparison, nil] the created comparison entity, or nil if comparison_hash is blank
  def comparison_entity
    return if comparison_hash.blank?
    return @comparison_entity if defined? @comparison_entity

    @comparison_entity = ::Operations::AccountComparison::Create.new.call(
      comparison_hash
    ).success
  end
end
