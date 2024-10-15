# frozen_string_literal: true

module Operations
  module Families
    # This class is responsible for processing the created or updated family payload.
    # Methods/Operations are called from within this class to validate, create request objects,
    # compare accounts, update SugarCRM, persist comparison and create response transmittable objects.
    class CreatedOrUpdatedProcessor
      include ::Operations::Transmittable::TransmittableUtils

      # Calls the processor with the given parameters.
      #
      # @param params [Hash] the parameters for the processor
      # @option params [String] :after_updated_at the timestamp after which updates are considered
      # @option params [String] :inbound_family_cv the inbound family CV payload
      # @return [Dry::Monads::Result] the result of the operation
      def call(params)
        after_updated_at_str, family_cv = yield validate(params)
        after_updated_at                = yield transform_timestamp(after_updated_at_str)
        request_objects                 = yield create_request_transmittable(family_cv, after_updated_at)
        comparison                      = yield compare_accounts(after_updated_at, request_objects[:subject])
        updated_comparison              = yield update_sugar_crm(comparison, request_objects)
        _persisted_result               = yield persist_comparison(updated_comparison, request_objects[:subject])
        _response_objects               = yield create_response_transmittable(updated_comparison, request_objects)

        Success(updated_comparison)
      end

      private

      # Creates a response transmittable.
      #
      # @param comparison_entity [::Entities::AccountComparison] the account comparison entity
      # @param request_objects [Hash] the request objects containing subject, job, and transmission
      # @option request_objects [::Family] :subject the subject family
      # @option request_objects [::Transmittable::Job] :job the job object
      # @option request_objects [::Transmittable::Transmission] :transmission the transmission object
      # @return [Dry::Monads::Result] the result of the response creation operation
      def create_response_transmittable(comparison_entity, request_objects)
        ::Operations::SugarCRM::Transmittable::Responses::Create.new.call(
          { comparison: comparison_entity, request_objects: request_objects }
        )
      end

      # Validates the parameters for the processor.
      #
      # @param params [Hash] the parameters to validate
      # @option params [String] :after_updated_at the timestamp after which updates are done in string format
      # @option params [String] :inbound_family_cv the inbound family CV payload
      # @return [Dry::Monads::Result] the result of the validation
      def validate(params)
        return Failure('After updated at timestamp and inbound family cv are required') if params.blank?
        return Failure('Inbound family cv payload not present.') if params[:inbound_family_cv].blank?
        return Failure('After updated at timestamp not present.') if params[:after_updated_at].blank?
        return Failure('Invalid After Updated At timestamp. Must be a valid timestamp in string format.') unless params[:after_updated_at].is_a?(String)

        Success([params[:after_updated_at], params[:inbound_family_cv]])
      rescue StandardError => e
        Failure("Invalid After Updated At timestamp. Error raised #{e.message}")
      end

      # Transforms the timestamp string to a Time object.
      #
      # @param after_updated_at_str [String] the timestamp string
      # @return [Dry::Monads::Result] the result of the transformation
      def transform_timestamp(after_updated_at_str)
        ::AcaEntities::Operations::DateTimeTransforms::ConvertStringToTime.new.call(
          { time_string: after_updated_at_str }
        )
      end

      # Creates request transmittable objects.
      #
      # @param family_cv [String] the inbound family CV payload
      # @param after_updated_at [Time] the timestamp after which updates are considered
      # @return [Dry::Monads::Result] the result of the request object generation operation
      def create_request_transmittable(family_cv, after_updated_at)
        ::Operations::SugarCRM::Transmittable::GenerateRequestObjects.new.call(
          {
            inbound_family_cv: family_cv,
            inbound_after_updated_at: after_updated_at
          }
        )
      end

      # Compares accounts based on the given timestamp and family.
      #
      # @param after_updated_at [Time] the timestamp after which updates are considered
      # @param family [::Family] the family object to compare
      # @return [Dry::Monads::Result] the result of the account comparison operation
      def compare_accounts(after_updated_at, family)
        ::Operations::SugarCRM::CompareRequest.new.call(
          {
            after_updated_at: after_updated_at,
            family: family
          }
        )
      end

      # Updates the SugarCRM system based on the comparison result and request objects.
      #
      # @param comparison [::Entities::AccountComparison] the account comparison entity
      # @param request_objects [Hash] the request objects containing subject, job, and transmission
      # @option request_objects [::Family] :subject the subject family
      # @option request_objects [::Transmittable::Job] :job the job object
      # @option request_objects [::Transmittable::Transmission] :transmission the transmission object
      # @return [Dry::Monads::Result] the result of the update operation
      def update_sugar_crm(comparison, request_objects)
        # If the comparison is no-op or stale, then we would simply return Success with a message that the update is not needed.
        return Success(comparison) if comparison.noop_or_stale?

        ::Operations::SugarCRM::Update.new.call(
          {
            comparison: comparison,
            request_objects: request_objects
          }
        )
      end

      # Persists the comparison result to the family object.
      #
      # @param comparison [::Entities::AccountComparison] the account comparison entity
      # @param family [::Family] the family object to update with the comparison payload
      # @return [Dry::Monads::Result] the result of the persistence operation
      def persist_comparison(comparison, family)
        family.comparison_payload = comparison.to_json
        family.save!
        Success(comparison)
      rescue StandardError => e
        Failure("Failed to persist the comparison. Error raised: #{e.message}")
      end
    end
  end
end
