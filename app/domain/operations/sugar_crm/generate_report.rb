# frozen_string_literal: true

require 'csv'

module Operations
  module SugarCRM
    class GenerateReport
      include Dry::Monads[:result, :do, :try]
      # pass in a date and limit to generate a report
      # add validation about the limit to 1000 and date
      # date range would be the input date beginning of day to the end of the input date day

      def call(params)
        values = yield validate_params(params)
        transmittable_data = yield construct_transmittable_data(values)
        transmittable_report = yield construct_transmittable_report(transmittable_data)

        Success(transmittable_report)
      end

      private

      def validate_params(params)
        return Failure("Date not present") if params[:date].blank? 
        return Failure("Date is not a date") unless params[:date].is_a?(Date)
        return Failure("limit") if params[:limit].blank?
        return Failure("Limit Exceeded") if params[:limit] > 1000
      
        Success(params)
      end

      def construct_transmittable_data(params)
        transmittable_data = []
        families_range = Family.where(created_at: params[:date].beginning_of_day..params[:date].end_of_day)
        families = families_range.order(created_at: :desc).limit(params[:limit]).to_a
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
                :transaction_created_at => transaction.created_at,
                :transaction_status => transaction_status,
                :transaction_errors => transaction_errors,
                :transmission_created_at => transmssion.created_at,
                :transmission_status => transmission_status,
                :transmission_errors => transmission_errors,
                :job_created_at => transmission.job.created_at,
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
          "Transaction Created At",
          "Transaction Status",
          "Transaction Errors",
          "Transmission Created At",
          "Transmission Status",
          "Transmission Errors",
          "Job Created At",
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
            csv << [data[:primary_person_hbx_id],
                    data[:transaction_created_at],
                    data[:transaction_status],
                    data[:transaction_errors],
                    data[:transmission_created_at],
                    data[:transmission_status],
                    data[:transmission_errors],
                    data[:job_created_at],
                    data[:job_status],
                    data[:job_errors],
                    data[:error_message],
                    data[:error_backtrace]]
          end
        end
        Success("Generated transmittable report: #{file_name}")
      end
    end
  end
end