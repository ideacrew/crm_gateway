# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe People::HandlePrimaryPersonUpdate, dbclean: :after_each do
  let(:payload) do
    "{\"hbx_id\":\"73018c3b05824fc7abd40d3f41973765\",\"person_name\":{\"first_name\":\"Doe\",\"middle_name\":null,\"last_name\":\"John\",\"name_sfx\":null,\"name_pfx\":null,\"full_name\":\"Doe John\",\"alternate_name\":null},\"person_demographics\":{\"ssn\":\"779672992\",\"no_ssn\":false,\"gender\":\"male\",\"dob\":\"1972-04-04\",\"date_of_death\":null,\"dob_check\":null,\"is_incarcerated\":true,\"ethnicity\":null,\"race\":null,\"tribal_id\":null,\"language_code\":null},\"person_health\":{\"is_tobacco_user\":\"unknown\",\"is_physically_disabled\":null},\"no_dc_address\":false,\"no_dc_address_reason\":null,\"is_homeless\":false,\"is_temporarily_out_of_state\":false,\"age_off_excluded\":false,\"is_applying_for_assistance\":null,\"is_active\":true,\"is_disabled\":null,\"person_relationships\":[],\"consumer_role\":{\"five_year_bar\":false,\"requested_coverage_start_date\":\"2021-09-15\",\"aasm_state\":\"unverified\",\"is_applicant\":true,\"birth_location\":null,\"marital_status\":null,\"is_active\":true,\"is_applying_coverage\":true,\"bookmark_url\":null,\"admin_bookmark_url\":null,\"contact_method\":\"mail\",\"language_preference\":\"English\",\"is_state_resident\":true,\"identity_validation\":\"na\",\"identity_update_reason\":null,\"application_validation\":\"na\",\"application_update_reason\":null,\"identity_rejected\":false,\"application_rejected\":false,\"documents\":[],\"vlp_documents\":[],\"ridp_documents\":[],\"verification_type_history_elements\":[],\"lawful_presence_determination\":{\"vlp_verified_at\":null,\"vlp_authority\":null,\"vlp_document_id\":null,\"citizen_status\":\"us_citizen\",\"citizenship_result\":null,\"qualified_non_citizenship_result\":null,\"aasm_state\":\"verification_pending\",\"ssa_responses\":[],\"ssa_requests\":[],\"vlp_responses\":[],\"vlp_requests\":[]},\"local_residency_responses\":[],\"local_residency_requests\":[]},\"resident_role\":null,\"individual_market_transitions\":[],\"verification_types\":[],\"broker_role\":null,\"user\":{},\"addresses\":[{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1111 Awesome Street NE\",\"address_2\":\"#111\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"},{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1112 Awesome Street NE\",\"address_2\":\"#112\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"}],\"emails\":[{\"kind\":\"home\",\"address\":\"example1@example.com\"},{\"kind\":\"home\",\"address\":\"example2@example.com\"}],\"phones\":[{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111111\",\"extension\":\"1\",\"primary\":null,\"full_phone_number\":\"20211111111\"},{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111112\",\"extension\":\"2\",\"primary\":null,\"full_phone_number\":\"20211111122\"}],\"documents\":[],\"timestamp\":{\"created_at\":\"2021-09-15T17:51:11.025+00:00\",\"modified_at\":\"2021-09-15T17:51:11.025+00:00\"}}"
  end

  subject do
    described_class.new
  end

  let!(:result) do
    VCR.use_cassette 'handle_primary_person' do
      subject.call(payload)
    end
  end
  
  it 'subject should be successful' do
    expect(result).to be_success
  end

  it 'creates and updates an event' do
    expect(subject.event.aasm_state).to eql("successful")
  end
  # rubocop:enable Layout/LineLength
end
