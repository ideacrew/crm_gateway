# frozen_string_literal: true

module Operations
  module Families
    # This class will create a Family object
    class Create
      include Dry::Monads[:result, :do, :try]

      def call(params)
        values = yield validate(params)

        @primary_person_hbx_id = yield find_primary_person_hbx_id(values[:inbound_family_cv])
        family_params = yield create_family_params(values)
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

      def create_family_params(values)
        Success(
          {
            correlation_id: values[:inbound_family_cv][:hbx_id],
            family_hbx_id: values[:inbound_family_cv][:hbx_id],
            inbound_raw_payload: values[:inbound_family_cv],
            inbound_payload: values[:inbound_family_cv],
            primary_person_hbx_id: @primary_person_hbx_id,
            job_id: values[:job].id,
            inbound_after_updated_at: values[:inbound_after_updated_at]
            # outbound_payload:
          }
        )
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
