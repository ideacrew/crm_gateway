# frozen_string_literal: true

module Operations
  module SugarCRM
    module Transmittable
      module Responses
        # Create operation for the response transmission and transactions.
        class Create
          include ::Operations::Transmittable::TransmittableUtils

          def call(params)
            _validated                  = yield validate(params)
            transmission_params         = yield construct_transmission_params
            @response_transmission      = yield create_response_transmission(transmission_params, { job: @job })
            account_transaction_params  = yield construct_account_transaction_params
            @account_transaction        = yield create_response_transaction(account_transaction_params, { job: @job, transmission: @response_transmission })
            contacts_transaction_params = yield construct_contacts_transaction_params
            @contacts_transactions      = yield create_response_transactions(contacts_transaction_params, { job: @job, transmission: @response_transmission })

            Success(transmittable_response)
          end

          private

          # Validates the provided parameters.
          #
          # @param [Hash] params The parameters to validate.
          # @option params [::Entities::AccountComparison] :comparison The account comparison object.
          # @option params [Hash] :request_objects The request objects containing subject, job, transmission, and request_transactions.
          # @option request_objects [::Family] :subject The family object.
          # @option request_objects [::Transmittable::Job] :job The job object.
          # @option request_objects [::Transmittable::Transmission] :transmission The transmission object.
          # @option request_objects [Array] :request_transactions The request transactions.
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure] The result of the validation.
          def validate(params)
            comparison = params[:comparison]
            family = params.dig(:request_objects, :subject)
            job = params.dig(:request_objects, :job)
            transmission = params.dig(:request_objects, :transmission)
            @request_transactions = params.dig(:request_objects, :request_transactions)

            if comparison.is_a?(::Entities::AccountComparison) && family.is_a?(::Family) && job.is_a?(::Transmittable::Job) && transmission.is_a?(::Transmittable::Transmission)
              @family = family
              @job = job
              @request_transmission = transmission
              @comparison = comparison
              @family_hbx_id = family.family_hbx_id

              Success('Valid comparison and request objects.')
            else
              Failure('Invalid comparison or request objects.')
            end
          end

          # Constructs the transmission parameters for the response transmission.
          #
          # @return [Dry::Monads::Result::Success<Hash>] The result containing the transmission parameters.
          def construct_transmission_params
            Success(
              {
                job_id: @job.id,
                job: @job,
                key: :family_created_or_updated_response,
                title: "Response Transmission of the family: #{@family_hbx_id}.",
                description: "Response Transmission that processes a family created or updated event for family: #{@family_hbx_id}.",
                publish_on: Time.zone.now,
                started_at: DateTime.now,
                subject_gid: @family.to_global_id.uri,
                event: 'acked',
                state_key: :acked,
                correlation_id: @family_hbx_id
              }
            )
          end

          # Constructs the account transaction parameters.
          #
          # @return [Dry::Monads::Result::Success<Hash>] The result containing the account transaction parameters.
          def construct_account_transaction_params
            Success(
              {
                job_id: @job.id,
                transmission: @response_transmission,
                subject: @family,
                key: :account_created_or_updated_response,
                title: "Account created or updated transaction for family: #{@family_hbx_id}.",
                description: "Account created or updated transaction for family: #{@family_hbx_id}.",
                publish_on: Time.zone.now,
                started_at: DateTime.now,
                event: 'acked',
                state_key: :acked,
                json_payload: @comparison.response_body,
                payload: @comparison.response_body,
                correlation_id: @family_hbx_id,
                subject_gid: @family.to_global_id.uri
              }
            )
          end

          # Constructs the contacts transaction parameters.
          #
          # @return [Dry::Monads::Result::Success<Array<Hash>>] The result containing an array of contact transaction parameters.
          def construct_contacts_transaction_params
            Success(
              @comparison.contacts.collect do |contact|
                {
                  job_id: @job.id,
                  transmission: @response_transmission,
                  subject: @family,
                  key: :contact_created_or_updated_response,
                  title: "Contact created or updated transaction for contact: #{contact.hbx_id}.",
                  description: "Contact created or updated transaction for contact: #{contact.hbx_id}.",
                  publish_on: Time.zone.now,
                  started_at: DateTime.now,
                  event: 'acked',
                  state_key: :acked,
                  json_payload: contact.response_body,
                  payload: contact.response_body,
                  correlation_id: contact.hbx_id,
                  subject_gid: @family.to_global_id.uri
                }
              end
            )
          end

          # Creates response transactions based on the provided parameters.
          #
          # @param [Array<Hash>] transactions_params The parameters for each transaction.
          # @param [Hash] request_objects The request objects containing necessary data.
          # @return [Dry::Monads::Result::Success<Array>] The result containing an array of transaction results.
          def create_response_transactions(transactions_params, request_objects)
            Success(
              transactions_params.collect do |transaction_params|
                result = create_response_transaction(transaction_params, request_objects)
                result.success? ? result.success : result.failure
              end
            )
          end

          # Constructs the transmittable response.
          #
          # @return [Hash] The transmittable response containing job, request transmission, response transmission, subject, request transactions, and response transactions.
          def transmittable_response
            {
              job: @job,
              request_transmission: @request_transmission,
              response_transmission: @response_transmission,
              subject: @family,
              request_transactions: @request_transactions,
              response_transactions: ([@account_transaction] + @contacts_transactions)
            }
          end
        end
      end
    end
  end
end
