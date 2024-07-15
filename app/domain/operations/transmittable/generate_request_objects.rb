# frozen_string_literal: true

module Operations
  module Transmittable
    # find or create job, then create response transmission/transaction, save payload and link to subject
    class GenerateRequestObjects
      include ::Operations::Transmittable::TransmittableUtils

      attr_reader :transaction, :transmission

      def call(params)
        values = yield validate(params)
        job_params = yield construct_job_params
        @job = yield create_job(job_params)
        transmission_params = yield construct_transmission_params(values)
        @transmission = yield create_request_transmission(transmission_params, @job)
        @family = yield create_family(values)
        transaction_params = yield construct_transaction_params
        @transaction = yield create_request_transaction(transaction_params, @job)

        request_objects
      end

      private

      def validate(params)
        return Failure("Inbound family cv payload not present") if params[:inbound_family_cv].blank?
        return Failure("After update timestamps not present") if params[:inbound_after_updated_at].blank?
        Success(params)
      end

      def create_family(params)
        ::Operations::Families::Create.new.call(params.merge({job: @job}))
      end

      def construct_job_params
        Success(
          {
            key: :family_created_or_updated,
            title: "Family Created or Updated",
            description: "Job that processes a family created or updated event",
            publish_on: DateTime.now,
            started_at: DateTime.now
          }
        )
      end

      def construct_transmission_params(params)
        # Using family hbx_id as correlation_id
        family_hbx_id = params[:inbound_family_cv][:hbx_id]
        Success(
          {
            job: @job,
            key: :family_created_or_updated,
            title: "Transmission that processes a family created or updated event for family: #{family_hbx_id}.",
            description: "Transmission that processes a family created or updated event for family: #{family_hbx_id}.",
            publish_on: Time.zone.now,
            started_at: DateTime.now,
            event: 'initial',
            state_key: :initial,
            correlation_id: family_hbx_id
          }
        )
      end

      def construct_transaction_params
        Success(
          {
            transmission: transmission,
            subject: @family,
            key: :family_created_or_updated,
            title: "Family created or updated transaction for family: #{@family.family_hbx_id}.",
            description: "Family created or updated transaction for family: #{@family.family_hbx_id}.",
            publish_on: Time.zone.now,
            started_at: DateTime.now,
            event: 'initial',
            state_key: :initial,
            correlation_id: @family.family_hbx_id
          }
        )
      end

      def validate_params(params)
        return Failure('Cannot save a failure response without a payload') if params[:payload].blank?
        return Failure('Cannot save a failure response without a key') unless params[:key].is_a?(Symbol)
        return Failure('Cannot link a subject without a correlation_id') unless params[:correlation_id].is_a?(String)
        return Failure('Cannot link a subject without a subject_gid') unless params[:subject_gid].is_a?(URI::GID)

        Success(
          {
            key: params[:key],
            title: params[:key].to_s.humanize.titleize,
            correlation_id: params[:correlation_id],
            started_at: DateTime.now,
            publish_on: DateTime.now,
            job_id: params[:job_id]
          }
        )
      end

      def find_subject(gid)
        subject = find_subject_by_global_id(gid)
        if subject.success?
          @subject = subject.value!
          return subject
        end
        add_errors(:find_subject, "Failed to find subject", { job: @job, transmission: @transmission })
        status_result = update_status(result.failure, :failed, { job: @job, transmission: @transmission })
        return status_result if status_result.failure?
        Failure("Failed to find subject")
      end

      def save_payload(payload)
        @transaction.json_payload = payload if payload.instance_of?(Hash)
        @transaction.xml_payload = payload if payload.instance_of?(String)
        if @transaction.save
          Success(@transaction)
        else
          add_errors(:save_payload, "Failed to save payload on response transaction", { job: @job, transmission: @transmission, transaction: @transaction })
          status_result = update_status(result.failure, :failed, { job: @job, transmission: @transmission, transaction: @transaction })
          return status_result if status_result.failure?
          Failure("Failed to save payload on response transaction")
        end
      end

      def request_objects
        Success(
          {
            transaction: @transaction,
            transmission: @transmission,
            job: @job,
            subject: @family
          }
        )
      end
    end
  end
end
