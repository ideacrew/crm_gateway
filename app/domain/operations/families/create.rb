# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module Families
    # This class will create a Family object
    class Create
      include Dry::Monads[:result, :do, :try]

      def call(params)
        values = yield validate(params)

        @primary_person_hbx_id = yield find_primary_person_hbx_id(values[:inbound_family_cv])
        outbound_account_entity = yield construct_outbound_account_entity(values[:inbound_family_cv])
        family_params = yield create_family_params(outbound_account_entity, values)
        create_family(family_params)
      end

      private

      def validate(params)
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After updated at timestamp not present") if params[:inbound_after_updated_at].blank?
        return Failure("Job not present") if params[:job].blank?

        Success(params)
      end

      def create_family(family_params)
        family = Family.new(family_params)
        if family.save
          Success(family)
        else
          Rails.logger.error { "Family creation failed: #{family.errors.full_messages}" }
          Failure("Family creation failed")
        end
      end

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

      def construct_outbound_account_entity(family_cv)
        inbound_family_entity = ::AcaEntities::Operations::CreateFamily.new.call(
          family_cv
        ).success
        account = ::AcaEntities::Crm::Transformers::FamilyTo::Account.new.call(inbound_family_entity)
        account.success? ? Success(account.value!) : Failure(account.failure)
      rescue StandardError => e
        Failure("Failed to construct outbound account entity: #{e.message} backtrace: #{e.backtrace.join("\n")} for family: #{family_cv[:hbx_id]}")
      end

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
