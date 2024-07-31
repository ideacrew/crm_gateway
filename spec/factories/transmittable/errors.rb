# frozen_string_literal: true

FactoryBot.define do
  factory :transmittable_error, class: '::Transmittable::Error' do
    key         { :test_key }
    message     { 'Error Message' }
  end
end