# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { :record => :once }

  c.filter_sensitive_data('<SUGAR_CRM_USERNAME>') do
    Rails.application.config.sugar_crm['username']
  end

  c.filter_sensitive_data('<SUGAR_CRM_PASSWORD>') do
    Rails.application.config.sugar_crm['password']
  end

  c.filter_sensitive_data('SUGAR_CRM_ENCODED_PASSWORD>') do
    Faraday::FlatParamsEncoder.encode(
      password: Rails.application.config.sugar_crm['password']
    )[9..-1]
  end
end
