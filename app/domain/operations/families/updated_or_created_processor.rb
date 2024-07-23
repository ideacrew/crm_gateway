# frozen_string_literal: true

module Operations
  module Families
    # This class will create or update Transmittable objects
    class UpdatedOrCreatedProcessor
      include ::Operations::Transmittable::TransmittableUtils

      def call(params)
        Rails.logger.debug params.inspect
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
        ::Operations::Transmittable::GenerateRequestObjects.new.call({inbound_family_cv: family_entity, inbound_after_updated_at: after_updated_at})
      end

      # Initialize the Family Entity and validation also happens as part of this. ::AcaEntities::Operations::CreateFamily.new.call(params[:inbound_family_cv])
      # Validate the 'after_updated_at' and convert this into a valid DateTime or Time for comparison.
      def validate(params)
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After updated at timestamp not present") if params[:after_updated_at].blank?

        Success([params[:inbound_family_cv], params[:after_updated_at]])
      end

      # def call(params)
      #   transmittable_objects = yield find_transmittable(params)
      # end

      private

      def find_transmittable(params)
        result = Operations::Transmittable::GenerateResponseObjects.new.call({job_id: params[:metadata][:headers]["job_id"],
                                                                              key: :families_created_or_updated_response,
                                                                              payload: params[:response],
                                                                              correlation_id: params[:person_hbx_id],
                                                                              subject_gid: subject})
        return result if result.success?
        add_errors(:find_transmittable, "Failed to create response objects due to #{result.failure}", { job: @job, transmission: @transmission })
        status_result = update_status(result.failure, :failed, { job: @job })
        return status_result if status_result.failure?
        result
      end
    end
  end
end
