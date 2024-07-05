# frozen_string_literal: true

FactoryBot.define do
  factory :transmittable_job, class: '::Transmittable::Job' do
    key         { :crm_update }
    started_at  { DateTime.now }
    publish_on  { DateTime.now }
    job_id      { 'Job_123' }
    title       { 'CRM Update' }
    description { 'CRM Update about a Family' }
  end
end
