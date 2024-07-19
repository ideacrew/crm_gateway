# frozen_string_literal: true

module Operations
  module Families
    # This class will create or update Transmittable objects
    class UpdatedOrCreatedProcessor
      include ::Operations::Transmittable::TransmittableUtils

      def call(params)
        after_updated_at, family_cv = yield validate(params)
        request_objects = yield create_request_transmittable(family_cv, after_updated_at)
        comparison_result = yield compare_accounts(after_updated_at, request_objects[:subject])
        # updated_result = yield update_sugar_crm(comparison_result, request_objects)
        # response_objects = yield create_response_transmittable(updated_result)
        Success(comparison_result)
      end

      def validate(params)
        return Failure('After updated at timestamp and inbound family cv are required') if params.blank?
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After updated at timestamp not present") if params[:after_updated_at].blank?

        Success([params[:after_updated_at].to_time, params[:inbound_family_cv]])
      rescue StandardError => e
        Failure("Invalid After Updated At timestamp. Error raised #{e.message}")
      end

      def create_request_transmittable(family_cv, after_updated_at)
        ::Operations::SugarCRM::Transmittable::GenerateRequestObjects.new.call(
          {
            inbound_family_cv: family_cv,
            inbound_after_updated_at: after_updated_at
          }
        )
      end

      def compare_accounts(after_updated_at, family)
        ::Operations::SugarCRM::CompareRequest.new.call(
          {
            after_updated_at: after_updated_at,
            family: family
          }
        )
      end

      def update_sugar_crm(comparison_result, request_objects)
        # If the comparison_result is no-op or stale, then wewould simply return Success with a message that the update is not needed.
      end
    end
  end
end
