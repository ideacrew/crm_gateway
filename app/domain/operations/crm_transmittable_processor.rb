# frozen_string_literal: true

require 'csv'

module Operations
  # Operation to generate a report of transmittable data
  class CRMTransmittableProcessor
    include Dry::Monads[:result, :do, :try]

    def call(params)
      values = yield validate_params(params)
      transmittable_data = yield construct_transmittable_data(values)
      transmittable_report = yield construct_transmittable_report(transmittable_data)

      Success(transmittable_report)
    end

    private

    def validate_params(params)
      return Success(params) if params.present?
      Failure("Params are not present")
    end

    def construct_transmittable_data(params)
      transmittable_data = []
      families = Family.order(created_at: :desc).limit(params).to_a
      families.each do |family|
        primary_person_hbx_id = family.primary_person_hbx_id
        family.transactions.each do |transaction|
          transaction_status = transaction.process_status.latest_state.to_s
          transaction_errors = transaction.transmittable_errors.present? ? transaction.transmittable_errors.first.message : ""
          transaction.transmissions.each do |transmission|
            transmission_status = transmission.process_status.latest_state.to_s
            transmission_errors = transmission.transmittable_errors.present? ? transmission.transmittable_errors.first.message : ""
            job_status = transmission.job.process_status.latest_state.to_s
            job_errors = transmission.job.transmittable_errors.present? ? transmission.job.transmittable_errors.first.message : ""

            transmittable_data << {
              :primary_person_hbx_id => primary_person_hbx_id,
              :transaction_status => transaction_status,
              :transaction_errors => transaction_errors,
              :transmission_status => transmission_status,
              :transmission_errors => transmission_errors,
              :job_status => job_status,
              :job_errors => job_errors
            }
          end
        rescue StandardError => e
          transmittable_data << { primary_person_hbx_id: primary_person_hbx_id, error_message: e.message, error_backtrace: e.backtrace[0..5].join('\n') }
        end
      end
      Success(transmittable_data)
    rescue StandardError => e
      Rails.logger.debug { "Error: #{e.message}" }
      Success(e)
    end

    def construct_transmittable_report(transmittable_data)
      field_names = [
        "Primary Person Hbx Id",
        "Transaction Status",
        "Transaction Errors",
        "Transmission Status",
        "Transmission Errors",
        "Job Status",
        "Job Errors",
        "Error Message",
        "Error Backtrace"
]

      date = DateTime.now.strftime('%Y_%m_%d')
      file_name = Rails.root.join("crm_transmittable_report_#{date}.csv")
      CSV.open(file_name, 'w', headers: true) do |csv|
        csv << field_names

        transmittable_data.each do |data|
          csv << [data[:primary_person_hbx_id], data[:transaction_status], data[:transaction_errors], data[:transmission_status], data[:transmission_errors], data[:job_status], data[:job_errors], data[:error_message], data[:error_backtrace]]
        end
      end
      Success("Generated transmittable report: #{file_name}")
    end
  end
end