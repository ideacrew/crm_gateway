# frozen_string_literal: true

# This script generates a CSV report with information about families, transactions, transmissions, and jobs.

# To run this script, execute the following command:
# bundle exec rails r script/crm_transmittable_report.rb 100

if ARGV[0].blank?
  puts "Please provide a limit"
  exit
end

limit = ARGV[0].to_i
date = ARGV[1]&.to_date || Date.today
result = Operations::SugarCRM::GenerateReport.new.call({limit: limit, date: date})

if result.success?
  puts result.success
else
  puts result.failure
end