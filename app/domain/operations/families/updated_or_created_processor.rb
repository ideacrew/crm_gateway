# frozen_string_literal: true

module Operations
  module Families
    # This class will create or update Transmittable objects
    class UpdatedOrCreatedProcessor
      include ::Operations::Transmittable::TransmittableUtils

      def call(params)
        family_entity, after_updated_at = yield validate(params)
        create_request_transmittable(family_entity, after_updated_at)
        # comparison_result = yield compare_accounts(after_updated_at, request_objects)
        # updated_result = yield update_sugar_crm(comparison_result, request_objects)
        # response_objects = yield create_response_transmittable(updated_result)
      end

      def update_sugar_crm(comparison_result, request_objects)
        # If the comparison_result is no-op or stale, then wewould simply return Success with a message that the update is not needed.
      end

      # This operation should always return a Success.
      # After this step, we will update the state of the request transmission, request transaction andthe Job
      def compare_accounts(request_objects)
        ::Operations::Accounts::Compare.new.call(after_updated_at, request_objects)
      end

      def create_request_transmittable(family_entity, after_updated_at)
        ::Operations::SugarCRM::Transmittable::GenerateRequestObjects.new.call({inbound_family_cv: family_entity, inbound_after_updated_at: after_updated_at})
      end

      def validate(params)
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After updated at timestamp not present") if params[:after_updated_at].blank?

        Success([params[:inbound_family_cv], params[:after_updated_at]])
      end

    end
  end
end
