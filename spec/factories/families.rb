# frozen_string_literal: true

FactoryBot.define do
  factory :family, class: 'Family' do
    correlation_id        { SecureRandom.uuid }
    family_hbx_id         { SecureRandom.uuid }
    primary_person_hbx_id { SecureRandom.uuid }
    inbound_raw_headers   { { 'Content-Type' => 'application/json' }.to_json }
    inbound_raw_payload   { { message: 'Raw payload from source' }.to_json }
    inbound_payload       { { family_details: 'Valid CV family entity hash' }.to_json }
    outbound_payload      { { account_details: 'Valid Account payload with Contacts' }.to_json }
    job_id                { SecureRandom.uuid }
  end
end
