# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# rubocop:disable Naming/VariableNumber
RSpec.describe Families::HandleFamilyUpdate, dbclean: :after_each do
  # Get an example of this from enroll
  let(:params) do
    {
      hbx_id: '10000',
      family_members: [
        {
          hbx_id: 'a95878c60b424759935bca542832d5b7',
          is_primary_applicant: true, is_consent_applicant: false,
          is_coverage_applicant: true, is_active: true,
          person: {
            hbx_id: 'a95878c60b424759935bca542832d5b7',
            person_name: {
              first_name: 'John',
              middle_name: nil,
              last_name: 'Smith1',
              name_sfx: nil,
              name_pfx: nil,
              full_name: 'John Smith1',
              alternate_name: nil
            },
            person_demographics: {
              ssn: '798092332',
              no_ssn: false,
              gender: 'male',
              dob: Date.today - 30.years,
              date_of_death: nil, dob_check: nil,
              is_incarcerated: true, ethnicity: nil,
              race: nil, tribal_id: nil, language_code: nil
            },
            person_health: {
              is_tobacco_user: 'unknown', is_physically_disabled: nil
            },
            no_dc_address: false, no_dc_address_reason: nil,
            is_homeless: false, is_temporarily_out_of_state: false,
            age_off_excluded: false, is_applying_for_assistance: nil,
            is_active: true, is_disabled: nil,
            person_relationships: [
              { relative: {
                hbx_id: 'a95878c60b424759935bca542832d5b7',
                first_name: 'John', middle_name: nil,
                last_name: 'Smith1', ssn: '798092332',
                no_ssn: false,
                dob: Date.today - 20.years, gender: 'male'
              },
                kind: 'self' },
              {
                relative: { hbx_id: '39543c3271b444f79a9c727f39b48f0c', first_name: 'John', middle_name: nil,
                            last_name: 'Smith2', ssn: '701846563', no_ssn: false, dob: Date.today - 15.years, gender: 'male' }, kind: 'spouse'
              }
            ], consumer_role: { five_year_bar: false, requested_coverage_start_date: Date.today, aasm_state: 'unverified', is_applicant: true, birth_location: nil, marital_status: nil, is_active: true, is_applying_coverage: true, bookmark_url: nil, admin_bookmark_url: nil, contact_method: 'mail', language_preference: 'English', is_state_resident: true, identity_validation: 'na', identity_update_reason: nil, application_validation: 'na', application_update_reason: nil, identity_rejected: false, application_rejected: false, documents: [], vlp_documents: [], ridp_documents: [], verification_type_history_elements: [], lawful_presence_determination: { vlp_verified_at: nil, vlp_authority: nil, vlp_document_id: nil, citizen_status: 'us_citizen', citizenship_result: nil, qualified_non_citizenship_result: nil, aasm_state: 'verification_pending', ssa_responses: [], ssa_requests: [], vlp_responses: [], vlp_requests: [] }, local_residency_responses: [], local_residency_requests: [] }, resident_role: nil, individual_market_transitions: [], verification_types: [], broker_role: nil, user: {}, addresses: [{ has_fixed_address: true, kind: 'home', address_1: '1111 Awesome Street NE', address_2: '#111', address_3: '', city: 'Washington', county: 'Hampden', state: 'DC', zip: '01001', country_name: 'United States of America' }, { has_fixed_address: true, kind: 'home', address_1: '1112 Awesome Street NE', address_2: '#112', address_3: '', city: 'Washington', county: 'Hampden', state: 'DC', zip: '01001', country_name: 'United States of America' }], emails: [{ kind: 'home', address: 'example1@example.com' }, { kind: 'home', address: 'example2@example.com' }], phones: [{ kind: 'home', country_code: '', area_code: '202', number: '1030404', extension: '', primary: nil, full_phone_number: '2021030404' }], documents: [], timestamp: { created_at: Date.today, modified_at: Date.today }
          }, timestamp: { created_at: Date.today, modified_at: Date.today }
        }, { hbx_id: '39543c3271b444f79a9c727f39b48f0c', is_primary_applicant: false, is_consent_applicant: false, is_coverage_applicant: true, is_active: true, person: { hbx_id: '39543c3271b444f79a9c727f39b48f0c', person_name: { first_name: 'John', middle_name: nil, last_name: 'Smith2', name_sfx: nil, name_pfx: nil, full_name: 'John Smith2', alternate_name: nil }, person_demographics: { ssn: '701846563', no_ssn: false, gender: 'male', dob: Date.today - 18.years, date_of_death: nil, dob_check: nil, is_incarcerated: true, ethnicity: nil, race: nil, tribal_id: nil, language_code: nil }, person_health: { is_tobacco_user: 'unknown', is_physically_disabled: nil }, no_dc_address: false, no_dc_address_reason: nil, is_homeless: false, is_temporarily_out_of_state: false, age_off_excluded: false, is_applying_for_assistance: nil, is_active: true, is_disabled: nil, person_relationships: [], consumer_role: { five_year_bar: false, requested_coverage_start_date: Date.today, aasm_state: 'unverified', is_applicant: true, birth_location: nil, marital_status: nil, is_active: true, is_applying_coverage: true, bookmark_url: nil, admin_bookmark_url: nil, contact_method: 'mail', language_preference: 'English', is_state_resident: true, identity_validation: 'na', identity_update_reason: nil, application_validation: 'na', application_update_reason: nil, identity_rejected: false, application_rejected: false, documents: [], vlp_documents: [], ridp_documents: [], verification_type_history_elements: [], lawful_presence_determination: { vlp_verified_at: nil, vlp_authority: nil, vlp_document_id: nil, citizen_status: 'us_citizen', citizenship_result: nil, qualified_non_citizenship_result: nil, aasm_state: 'verification_pending', ssa_responses: [], ssa_requests: [], vlp_responses: [], vlp_requests: [] }, local_residency_responses: [], local_residency_requests: [] }, resident_role: nil, individual_market_transitions: [], verification_types: [], broker_role: nil, user: {}, addresses: [{ has_fixed_address: true, kind: 'home', address_1: '1113 Awesome Street NE', address_2: '#113', address_3: '', city: 'Washington', county: 'Hampden', state: 'DC', zip: '01001', country_name: 'United States of America' }, { has_fixed_address: true, kind: 'home', address_1: '1114 Awesome Street NE', address_2: '#114', address_3: '', city: 'Washington', county: 'Hampden', state: 'DC', zip: '01001', country_name: 'United States of America' }], emails: [{ kind: 'home', address: 'example3@example.com' }, { kind: 'home', address: 'example4@example.com' }], phones: [{ kind: 'home', country_code: '', area_code: '202', number: '1030404', extension: '', primary: nil, full_phone_number: '2021030404' }], documents: [], timestamp: { created_at: Date.today, modified_at: Date.today } }, timestamp: { created_at: Date.today, modified_at: Date.today } }
      ], timestamp: { created_at: Date.today, modified_at: Date.today }
    }
  end
  let(:update_handler) do
    Families::HandleFamilyUpdate.new.call(params)
  end

  it 'should handle family update and create valid account/contact' do
    expect(update_handler.errors.to_h).to eq({})
  end
end

# rubocop:enable Layout/LineLength
# rubocop:enable Naming/VariableNumber
