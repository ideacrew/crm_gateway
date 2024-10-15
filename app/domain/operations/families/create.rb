# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module Families
    # This class will create a Family object
    # @example
    #   create_operation = Operations::Families::Create.new
    #   result = create_operation.call(params)
    class Create
      include Dry::Monads[:result, :do, :try]

      # Creates a Family object
      # @param params [Hash] the parameters required to create a family
      # @option params [Hash] :inbound_family_cv the inbound family CV payload
      # @option params [Time] :inbound_after_updated_at the timestamp after which updates are considered
      # @option params [Job] :job the job associated with the family creation
      # @return [Dry::Monads::Result] the result of the family creation operation
      def call(params)
        values                  = yield validate(params)
        @primary_person_hbx_id  = yield find_primary_person_hbx_id(values[:inbound_family_cv])
        family_entity           = yield construct_family_entity(values[:inbound_family_cv])
        outbound_account_hash   = yield fetch_outbound_account_hash(family_entity)
        outbound_account_entity = yield construct_outbound_account_entity(outbound_account_hash)
        family_params           = yield create_family_params(outbound_account_entity, values)

        create_family(family_params)
      end

      private

      # Validates the input parameters
      # @param params [Hash] the parameters to validate
      # @return [Dry::Monads::Result] the result of the validation
      def validate(params)
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After updated at timestamp not present") if params[:inbound_after_updated_at].blank?
        return Failure("Job not present") if params[:job].blank?

        Success(params)
      end

      # Creates a Family object and saves it to the database
      # @param family_params [Hash] the parameters required to create a family
      # @return [Dry::Monads::Result] the result of the family creation
      def create_family(family_params)
        family = Family.new(family_params)
        if family.save
          Success(family)
        else
          Rails.logger.error { "Family creation failed: #{family.errors.full_messages}" }
          Failure("Family creation failed")
        end
      end

      # Constructs the parameters required to create a family
      # @param outbound_account_entity [Object] the outbound account entity
      # @param values [Hash] the validated input parameters
      # @return [Dry::Monads::Result] the result containing the family parameters
      def create_family_params(outbound_account_entity, values)
        Success(
          {
            correlation_id: values[:inbound_family_cv][:hbx_id],
            family_hbx_id: values[:inbound_family_cv][:hbx_id],
            inbound_raw_payload: values[:inbound_family_cv],
            inbound_payload: values[:inbound_family_cv].to_json,
            outbound_payload: outbound_account_entity.to_json,
            primary_person_hbx_id: @primary_person_hbx_id,
            job_id: values[:job].id,
            inbound_after_updated_at: values[:inbound_after_updated_at]
          }
        )
      end

      # Constructs a family entity from the inbound family CV payload
      # @param family_cv [Hash] the inbound family CV payload
      # @return [Dry::Monads::Result] the result containing the family entity
      def construct_family_entity(family_cv)
        ::AcaEntities::Operations::CreateFamily.new.call(family_cv)
      end

      # Fetches the outbound account hash from the family entity
      # @param family_entity [Object] the family entity
      # @return [Dry::Monads::Result] the result containing the outbound account hash
      def fetch_outbound_account_hash(family_entity)
        ::AcaEntities::Crm::Transformers::FamilyTo::Account.new.call(family_entity)
      end

      # Constructs an outbound account entity from the outbound account hash
      # @param outbound_account_hash [Hash] the outbound account hash
      # @return [Dry::Monads::Result] the result containing the outbound account entity
      def construct_outbound_account_entity(outbound_account_hash)
        ::AcaEntities::Crm::Operations::CreateAccount.new.call(outbound_account_hash)
      end

      # Finds the primary person's HBX ID from the family CV payload
      # @param family_cv_payload [Hash] the family CV payload
      # @return [Dry::Monads::Result] the result containing the primary person's HBX ID
      def find_primary_person_hbx_id(family_cv_payload)
        primary_family_member = family_cv_payload[:family_members].detect do |family_member|
          family_member[:is_primary_applicant] == true
        end
        return Failure("Primary person not found") if primary_family_member.blank?
        Success(primary_family_member[:person][:hbx_id])
      end
    end
  end
end
