# frozen_string_literal: true

module Operations
  module Families
    # This class will create or update Transmittable objects
    class UpdatedOrCreatedProcessor
      include ::Operations::Transmittable::TransmittableUtils

      def call(params)
        family_entity, after_updated_at = yield validate(params)
        request_transmittable = yield create_request_transmittable(family_entity, after_updated_at)
        create_outbound_payload(request_transmittable)
        # comparison_result = yield compare_accounts(after_updated_at, request_objects)
        # updated_result = yield update_sugar_crm(comparison_result, request_objects)
        # response_objects = yield create_response_transmittable(updated_result)
      end

      def create_outbound_payload(params)
        family = params[:subject]
        family_entity = family.inbound_family_entity

        outbound_payload = ::Operations::Transformers::GenerateOutboundPayload.new.call(family_entity)
        if outbound_payload.success?
          family.outbound_payload = outbound_payload.value!.to_json
          family.save
        else
          Rails.logger.info {"Failed to create outbound payload for family: #{family.primary_person_hbx_id} due to: #{outbound_payload.failure}"}
          add_error(:create_outbound_payload, "Failed to create outbound payload for family: #{family.primary_person_hbx_id} due to: #{outbound_payload.failure}", { job: params[:job], transmission: params[:transmission], transaction: params[:transaction] })
          return Failure("Failed to create outbound payload for family: #{family.primary_person_hbx_id} due to: #{outbound_payload.failure}")
        end
        Success(family)
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
