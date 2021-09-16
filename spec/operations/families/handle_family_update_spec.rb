# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# rubocop:disable Naming/VariableNumber
RSpec.describe SugarCRM::Operations::Families::HandleFamilyUpdate, dbclean: :after_each do
  # Get an example of this from enroll
  let(:payload) do
     "{\"hbx_id\":\"10001\",\"family_members\":[{\"hbx_id\":\"10001\",\"is_primary_applicant\":true,\"is_consent_applicant\":false,\"is_coverage_applicant\":true,\"is_active\":true,\"person\":{\"hbx_id\":\"7ed63908ff7449feb4d38830ac88b9ec\",\"person_name\":{\"first_name\":\"Doe\",\"middle_name\":null,\"last_name\":\"John\",\"name_sfx\":null,\"name_pfx\":null,\"full_name\":\"Doe John\",\"alternate_name\":null},\"person_demographics\":{\"ssn\":null,\"no_ssn\":true,\"gender\":\"male\",\"dob\":\"1972-04-04\",\"date_of_death\":null,\"dob_check\":null,\"is_incarcerated\":false,\"ethnicity\":null,\"race\":null,\"tribal_id\":null,\"language_code\":null},\"person_health\":{\"is_tobacco_user\":\"unknown\",\"is_physically_disabled\":null},\"no_dc_address\":false,\"no_dc_address_reason\":null,\"is_homeless\":false,\"is_temporarily_out_of_state\":false,\"age_off_excluded\":false,\"is_applying_for_assistance\":null,\"is_active\":true,\"is_disabled\":null,\"person_relationships\":[{\"relative\":{\"hbx_id\":\"7ed63908ff7449feb4d38830ac88b9ec\",\"first_name\":\"Doe\",\"middle_name\":null,\"last_name\":\"John\",\"ssn\":null,\"no_ssn\":true,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"self\"},{\"relative\":{\"hbx_id\":\"4bb301e2936b46518705a2acc709eed4\",\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith1\",\"ssn\":\"768252862\",\"no_ssn\":false,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"spouse\"},{\"relative\":{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith2\",\"ssn\":\"740491753\",\"no_ssn\":false,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"child\"}],\"consumer_role\":null,\"resident_role\":null,\"individual_market_transitions\":[],\"verification_types\":[],\"broker_role\":null,\"user\":{},\"addresses\":[{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1119 Awesome Street NE\",\"address_2\":\"#119\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"},{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1120 Awesome Street NE\",\"address_2\":\"#120\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"}],\"emails\":[{\"kind\":\"home\",\"address\":\"example3@example.com\"},{\"kind\":\"home\",\"address\":\"example4@example.com\"}],\"phones\":[{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111119\",\"extension\":\"9\",\"primary\":null,\"full_phone_number\":\"20211111199\"},{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111120\",\"extension\":\"10\",\"primary\":null,\"full_phone_number\":\"202111112010\"}],\"documents\":[],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.434+00:00\",\"modified_at\":\"2021-09-15T17:46:11.434+00:00\"}},\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.649+00:00\",\"modified_at\":\"2021-09-15T17:46:11.649+00:00\"}},{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"is_primary_applicant\":false,\"is_consent_applicant\":false,\"is_coverage_applicant\":true,\"is_active\":true,\"person\":{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"person_name\":{\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith2\",\"name_sfx\":null,\"name_pfx\":null,\"full_name\":\"John Smith2\",\"alternate_name\":null},\"person_demographics\":{\"ssn\":\"740491753\",\"no_ssn\":false,\"gender\":\"male\",\"dob\":\"1972-04-04\",\"date_of_death\":null,\"dob_check\":null,\"is_incarcerated\":true,\"ethnicity\":null,\"race\":null,\"tribal_id\":null,\"language_code\":null},\"person_health\":{\"is_tobacco_user\":\"unknown\",\"is_physically_disabled\":null},\"no_dc_address\":false,\"no_dc_address_reason\":null,\"is_homeless\":false,\"is_temporarily_out_of_state\":false,\"age_off_excluded\":false,\"is_applying_for_assistance\":null,\"is_active\":true,\"is_disabled\":null,\"person_relationships\":[],\"consumer_role\":{\"five_year_bar\":false,\"requested_coverage_start_date\":\"2021-09-15\",\"aasm_state\":\"unverified\",\"is_applicant\":true,\"birth_location\":null,\"marital_status\":null,\"is_active\":true,\"is_applying_coverage\":true,\"bookmark_url\":null,\"admin_bookmark_url\":null,\"contact_method\":\"mail\",\"language_preference\":\"English\",\"is_state_resident\":true,\"identity_validation\":\"na\",\"identity_update_reason\":null,\"application_validation\":\"na\",\"application_update_reason\":null,\"identity_rejected\":false,\"application_rejected\":false,\"documents\":[],\"vlp_documents\":[],\"ridp_documents\":[],\"verification_type_history_elements\":[],\"lawful_presence_determination\":{\"vlp_verified_at\":null,\"vlp_authority\":null,\"vlp_document_id\":null,\"citizen_status\":\"us_citizen\",\"citizenship_result\":null,\"qualified_non_citizenship_result\":null,\"aasm_state\":\"verification_pending\",\"ssa_responses\":[],\"ssa_requests\":[],\"vlp_responses\":[],\"vlp_requests\":[]},\"local_residency_responses\":[],\"local_residency_requests\":[]},\"resident_role\":null,\"individual_market_transitions\":[],\"verification_types\":[],\"broker_role\":null,\"user\":{},\"addresses\":[{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1123 Awesome Street NE\",\"address_2\":\"#123\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"},{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1124 Awesome Street NE\",\"address_2\":\"#124\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"}],\"emails\":[{\"kind\":\"home\",\"address\":\"example7@example.com\"},{\"kind\":\"home\",\"address\":\"example8@example.com\"}],\"phones\":[{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111123\",\"extension\":\"13\",\"primary\":null,\"full_phone_number\":\"202111112313\"},{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111124\",\"extension\":\"14\",\"primary\":null,\"full_phone_number\":\"202111112414\"}],\"documents\":[],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.562+00:00\",\"modified_at\":\"2021-09-15T17:46:11.562+00:00\"}},\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.649+00:00\",\"modified_at\":\"2021-09-15T17:46:11.649+00:00\"}}],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.650+00:00\",\"modified_at\":\"2021-09-15T17:46:11.663+00:00\"}}"
  end

  describe "call" do

    let(:account_params) do
      {
        :hbxid_c=>"10001",
        :name=>"John Doe",
        :email1=>"example1@example.com",
        :dob_c=>"1972-04-04",
        :billing_address_street=>"1111 Awesome Street NE",
        :billing_address_street_2=>"#111",
        :billing_address_street_3=>"",
        :billing_address_street_4=>nil,
        :billing_address_city=>"Washington",
        :billing_address_postalcode=>"01001",
        :billing_address_state=>"DC",
        :phone_office=>"2021030404"
      }
    end

    let(:contact_params) do
      {
        :hbxid_c=>"10001",
        :first_name=>"John",
        :last_name=>"Jacob",
        :phone_mobile=>"2021030404",
        :email1=>"example1@example.com"
      }
    end

    subject do
      described_class.new
    end
    context "with successful username and password" do

      let(:result) do
        VCR.use_cassette 'handle_family_update' do
          account = SugarCRM::Services::Connection.new.create_account(payload: account_params)
          SugarCRM::Services::Connection.new.create_contact_for_account(payload: contact_params.merge('account.id': account['id']))
          subject.call(payload)
        end
      end

      it 'subject should be successful' do
        expect(result).to be_success
      end

      it 'creates and updates an event' do
        result
        expect(subject.event_log.aasm_state).to eql("successful")
      end
    end

    context "without an existing account" do

      let(:bad_payload) do
        "{\"hbx_id\":\"100z01\",\"family_members\":[{\"hbx_id\":\"100z01\",\"is_primary_applicant\":true,\"is_consent_applicant\":false,\"is_coverage_applicant\":true,\"is_active\":true,\"person\":{\"hbx_id\":\"7ed63908ff7449feb4d38830ac88b9ec\",\"person_name\":{\"first_name\":\"Doe\",\"middle_name\":null,\"last_name\":\"John\",\"name_sfx\":null,\"name_pfx\":null,\"full_name\":\"Doe John\",\"alternate_name\":null},\"person_demographics\":{\"ssn\":null,\"no_ssn\":true,\"gender\":\"male\",\"dob\":\"1972-04-04\",\"date_of_death\":null,\"dob_check\":null,\"is_incarcerated\":false,\"ethnicity\":null,\"race\":null,\"tribal_id\":null,\"language_code\":null},\"person_health\":{\"is_tobacco_user\":\"unknown\",\"is_physically_disabled\":null},\"no_dc_address\":false,\"no_dc_address_reason\":null,\"is_homeless\":false,\"is_temporarily_out_of_state\":false,\"age_off_excluded\":false,\"is_applying_for_assistance\":null,\"is_active\":true,\"is_disabled\":null,\"person_relationships\":[{\"relative\":{\"hbx_id\":\"7ed63908ff7449feb4d38830ac88b9ec\",\"first_name\":\"Doe\",\"middle_name\":null,\"last_name\":\"John\",\"ssn\":null,\"no_ssn\":true,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"self\"},{\"relative\":{\"hbx_id\":\"4bb301e2936b46518705a2acc709eed4\",\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith1\",\"ssn\":\"768252862\",\"no_ssn\":false,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"spouse\"},{\"relative\":{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith2\",\"ssn\":\"740491753\",\"no_ssn\":false,\"dob\":\"1972-04-04\",\"gender\":\"male\"},\"kind\":\"child\"}],\"consumer_role\":null,\"resident_role\":null,\"individual_market_transitions\":[],\"verification_types\":[],\"broker_role\":null,\"user\":{},\"addresses\":[{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1119 Awesome Street NE\",\"address_2\":\"#119\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"},{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1120 Awesome Street NE\",\"address_2\":\"#120\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"}],\"emails\":[{\"kind\":\"home\",\"address\":\"example3@example.com\"},{\"kind\":\"home\",\"address\":\"example4@example.com\"}],\"phones\":[{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111119\",\"extension\":\"9\",\"primary\":null,\"full_phone_number\":\"20211111199\"},{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111120\",\"extension\":\"10\",\"primary\":null,\"full_phone_number\":\"202111112010\"}],\"documents\":[],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.434+00:00\",\"modified_at\":\"2021-09-15T17:46:11.434+00:00\"}},\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.649+00:00\",\"modified_at\":\"2021-09-15T17:46:11.649+00:00\"}},{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"is_primary_applicant\":false,\"is_consent_applicant\":false,\"is_coverage_applicant\":true,\"is_active\":true,\"person\":{\"hbx_id\":\"b7bfbc6b58f340169de7f0772e88230f\",\"person_name\":{\"first_name\":\"John\",\"middle_name\":null,\"last_name\":\"Smith2\",\"name_sfx\":null,\"name_pfx\":null,\"full_name\":\"John Smith2\",\"alternate_name\":null},\"person_demographics\":{\"ssn\":\"740491753\",\"no_ssn\":false,\"gender\":\"male\",\"dob\":\"1972-04-04\",\"date_of_death\":null,\"dob_check\":null,\"is_incarcerated\":true,\"ethnicity\":null,\"race\":null,\"tribal_id\":null,\"language_code\":null},\"person_health\":{\"is_tobacco_user\":\"unknown\",\"is_physically_disabled\":null},\"no_dc_address\":false,\"no_dc_address_reason\":null,\"is_homeless\":false,\"is_temporarily_out_of_state\":false,\"age_off_excluded\":false,\"is_applying_for_assistance\":null,\"is_active\":true,\"is_disabled\":null,\"person_relationships\":[],\"consumer_role\":{\"five_year_bar\":false,\"requested_coverage_start_date\":\"2021-09-15\",\"aasm_state\":\"unverified\",\"is_applicant\":true,\"birth_location\":null,\"marital_status\":null,\"is_active\":true,\"is_applying_coverage\":true,\"bookmark_url\":null,\"admin_bookmark_url\":null,\"contact_method\":\"mail\",\"language_preference\":\"English\",\"is_state_resident\":true,\"identity_validation\":\"na\",\"identity_update_reason\":null,\"application_validation\":\"na\",\"application_update_reason\":null,\"identity_rejected\":false,\"application_rejected\":false,\"documents\":[],\"vlp_documents\":[],\"ridp_documents\":[],\"verification_type_history_elements\":[],\"lawful_presence_determination\":{\"vlp_verified_at\":null,\"vlp_authority\":null,\"vlp_document_id\":null,\"citizen_status\":\"us_citizen\",\"citizenship_result\":null,\"qualified_non_citizenship_result\":null,\"aasm_state\":\"verification_pending\",\"ssa_responses\":[],\"ssa_requests\":[],\"vlp_responses\":[],\"vlp_requests\":[]},\"local_residency_responses\":[],\"local_residency_requests\":[]},\"resident_role\":null,\"individual_market_transitions\":[],\"verification_types\":[],\"broker_role\":null,\"user\":{},\"addresses\":[{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1123 Awesome Street NE\",\"address_2\":\"#123\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"},{\"has_fixed_address\":true,\"kind\":\"home\",\"address_1\":\"1124 Awesome Street NE\",\"address_2\":\"#124\",\"address_3\":\"\",\"city\":\"Washington\",\"county\":\"Hampden\",\"state\":\"DC\",\"zip\":\"01001\",\"country_name\":\"United States of America\"}],\"emails\":[{\"kind\":\"home\",\"address\":\"example7@example.com\"},{\"kind\":\"home\",\"address\":\"example8@example.com\"}],\"phones\":[{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111123\",\"extension\":\"13\",\"primary\":null,\"full_phone_number\":\"202111112313\"},{\"kind\":\"home\",\"country_code\":\"\",\"area_code\":\"202\",\"number\":\"1111124\",\"extension\":\"14\",\"primary\":null,\"full_phone_number\":\"202111112414\"}],\"documents\":[],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.562+00:00\",\"modified_at\":\"2021-09-15T17:46:11.562+00:00\"}},\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.649+00:00\",\"modified_at\":\"2021-09-15T17:46:11.649+00:00\"}}],\"timestamp\":{\"created_at\":\"2021-09-15T17:46:11.650+00:00\",\"modified_at\":\"2021-09-15T17:46:11.663+00:00\"}}"
      end

      let(:result) do
        VCR.use_cassette 'handle_family_update_without_existing_account' do
          subject.call(bad_payload)
        end
      end

      it "event shound have an error" do
        result
        expect(subject.event_log.error_message).to eql("{:error=>\"no account found\", :error_message=>\"No account found\"}")
      end
    end
  end
end

# rubocop:enable Layout/LineLength
# rubocop:enable Naming/VariableNumber
