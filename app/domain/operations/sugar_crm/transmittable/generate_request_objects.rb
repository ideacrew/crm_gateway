# frozen_string_literal: true

module Operations
  module SugarCRM
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
          account_transaction_params = yield construct_account_transaction_params
          @account_transaction = yield create_request_transaction(account_transaction_params, @job)
          contacts_transactions_params = yield construct_contacts_transactions_params
          _contact_transaction = yield create_contacts_request_transactions(contacts_transactions_params)

          Success(request_objects)
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

        def construct_account_transaction_params
          Success(
            {
              transmission: transmission,
              subject: @family,
              key: :account_created_or_updated,
              title: "Account created or updated transaction for family: #{@family.family_hbx_id}.",
              description: "Account created or updated transaction for family: #{@family.family_hbx_id}.",
              publish_on: Time.zone.now,
              started_at: DateTime.now,
              event: 'initial',
              state_key: :initial,
              correlation_id: @family.family_hbx_id
            }
          )
        end

        def create_contacts_request_transactions(contacts_transactions_params)
          contact_transactions = contacts_transactions_params.each do |contact_transaction_params|
            create_request_transaction(contact_transaction_params, @job)
          end
          Success(contact_transactions)
        end

        def construct_contacts_transactions_params
          family_entity = @family.inbound_family_entity
          Success(
            family_entity.family_members.collect do |family_member|
              {
                transmission: transmission,
                subject: @family,
                key: :contact_created_or_updated,
                title: "Contact created or updated transaction for family: #{@family.family_hbx_id}.",
                description: "Contact created or updated transaction for family: #{@family.family_hbx_id}.",
                publish_on: Time.zone.now,
                started_at: DateTime.now,
                event: 'initial',
                state_key: :initial,
                correlation_id: family_member.hbx_id
              }
            end
          )
        end

        def request_objects
          {
            transaction: @account_transaction,
            transmission: @transmission,
            job: @job,
            subject: @family
          }
        end
      end
    end
  end
end
