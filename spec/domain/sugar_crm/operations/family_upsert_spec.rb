
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::FamilyUpsert do

  let(:payload) do
    {
      "hbx_id"=>"a95878c60b424759935bca542832d5b7",
      "family_members"=>
       [{"hbx_id"=>"a95878c60b424759935bca542832d5b7",
         "is_primary_applicant"=>true,
         "is_consent_applicant"=>false,
         "is_coverage_applicant"=>true,
         "is_active"=>true,
         "person"=>
          {"hbx_id"=>"a95878c60b424759935bca542832d5b7",
           "person_name"=>
            {"first_name"=>"Doe",
             "middle_name"=>nil,
             "last_name"=>"John",
             "name_sfx"=>nil,
             "name_pfx"=>nil,
             "full_name"=>"Doe John",
             "alternate_name"=>nil},
           "person_demographics"=>
            {"ssn"=>nil,
             "no_ssn"=>true,
             "gender"=>"male",
             "dob"=>"1972-04-04",
             "date_of_death"=>nil,
             "dob_check"=>nil,
             "is_incarcerated"=>false,
             "ethnicity"=>nil,
             "race"=>nil,
             "tribal_id"=>nil,
             "language_code"=>nil},
           "person_health"=>
            {"is_tobacco_user"=>"unknown", "is_physically_disabled"=>nil},
           "no_dc_address"=>false,
           "no_dc_address_reason"=>nil,
           "is_homeless"=>false,
           "is_temporarily_out_of_state"=>false,
           "age_off_excluded"=>false,
           "is_applying_for_assistance"=>nil,
           "is_active"=>true,
           "is_disabled"=>nil,
           "person_relationships"=>
            [{"relative"=>
               {"hbx_id"=>"a95878c60b424759935bca542832d5b7",
                "first_name"=>"Doe",
                "middle_name"=>nil,
                "last_name"=>"John",
                "ssn"=>nil,
                "no_ssn"=>true,
                "dob"=>"1972-04-04",
                "gender"=>"male"},
              "kind"=>"self"},
             {"relative"=>
               {"hbx_id"=>"4bb301e2936b46518705a2acc709eed4",
                "first_name"=>"John",
                "middle_name"=>nil,
                "last_name"=>"Smith1",
                "ssn"=>"768252862",
                "no_ssn"=>false,
                "dob"=>"1972-04-04",
                "gender"=>"male"},
              "kind"=>"spouse"},
             {"relative"=>
               {"hbx_id"=>"b7bfbc6b58f340169de7f0772e88230f",
                "first_name"=>"John",
                "middle_name"=>nil,
                "last_name"=>"Smith2",
                "ssn"=>"740491753",
                "no_ssn"=>false,
                "dob"=>"1972-04-04",
                "gender"=>"male"},
              "kind"=>"child"}],
           "consumer_role"=>nil,
           "resident_role"=>nil,
           "individual_market_transitions"=>[],
           "verification_types"=>[],
           "broker_role"=>nil,
           "user"=>{},
           "addresses"=>
            [{"has_fixed_address"=>true,
              "kind"=>"home",
              "address_1"=>"1119 Awesome Street NE",
              "address_2"=>"#119",
              "address_3"=>"",
              "city"=>"Washington",
              "county"=>"Hampden",
              "state"=>"DC",
              "zip"=>"01001",
              "country_name"=>"United States of America"},
             {"has_fixed_address"=>true,
              "kind"=>"home",
              "address_1"=>"1120 Awesome Street NE",
              "address_2"=>"#120",
              "address_3"=>"",
              "city"=>"Washington",
              "county"=>"Hampden",
              "state"=>"DC",
              "zip"=>"01001",
              "country_name"=>"United States of America"}],
           "emails"=>
            [{"kind"=>"home", "address"=>"example3@example.com"},
             {"kind"=>"home", "address"=>"example4@example.com"}],
           "phones"=>
            [{"kind"=>"home",
              "country_code"=>"",
              "area_code"=>"202",
              "number"=>"1111119",
              "extension"=>"9",
              "primary"=>nil,
              "full_phone_number"=>"20211111199"},
             {"kind"=>"home",
              "country_code"=>"",
              "area_code"=>"202",
              "number"=>"1111120",
              "extension"=>"10",
              "primary"=>nil,
              "full_phone_number"=>"202111112010"}],
           "documents"=>[],
           "timestamp"=>
            {"created_at"=>"2021-09-15T17:46:11.434+00:00",
             "modified_at"=>"2021-09-15T17:46:11.434+00:00"}},
         "timestamp"=>
          {"created_at"=>"2021-09-15T17:46:11.649+00:00",
           "modified_at"=>"2021-09-15T17:46:11.649+00:00"}},
        {"hbx_id"=>"b7bfbc6b58f340169de7f0772e88230f",
         "is_primary_applicant"=>false,
         "is_consent_applicant"=>false,
         "is_coverage_applicant"=>true,
         "is_active"=>true,
         "person"=>
          {"hbx_id"=>"b7bfbc6b58f340169de7f0772e88230f",
           "person_name"=>
            {"first_name"=>"John",
             "middle_name"=>nil,
             "last_name"=>"Smith2",
             "name_sfx"=>nil,
             "name_pfx"=>nil,
             "full_name"=>"John Smith2",
             "alternate_name"=>nil},
           "person_demographics"=>
            {"ssn"=>"740491753",
             "no_ssn"=>false,
             "gender"=>"male",
             "dob"=>"1972-04-04",
             "date_of_death"=>nil,
             "dob_check"=>nil,
             "is_incarcerated"=>true,
             "ethnicity"=>nil,
             "race"=>nil,
             "tribal_id"=>nil,
             "language_code"=>nil},
           "person_health"=>
            {"is_tobacco_user"=>"unknown", "is_physically_disabled"=>nil},
           "no_dc_address"=>false,
           "no_dc_address_reason"=>nil,
           "is_homeless"=>false,
           "is_temporarily_out_of_state"=>false,
           "age_off_excluded"=>false,
           "is_applying_for_assistance"=>nil,
           "is_active"=>true,
           "is_disabled"=>nil,
           "person_relationships"=>[],
           "consumer_role"=>
            {"five_year_bar"=>false,
             "requested_coverage_start_date"=>"2021-09-15",
             "aasm_state"=>"unverified",
             "is_applicant"=>true,
             "birth_location"=>nil,
             "marital_status"=>nil,
             "is_active"=>true,
             "is_applying_coverage"=>true,
             "bookmark_url"=>nil,
             "admin_bookmark_url"=>nil,
             "contact_method"=>"mail",
             "language_preference"=>"English",
             "is_state_resident"=>true,
             "identity_validation"=>"na",
             "identity_update_reason"=>nil,
             "application_validation"=>"na",
             "application_update_reason"=>nil,
             "identity_rejected"=>false,
             "application_rejected"=>false,
             "documents"=>[],
             "vlp_documents"=>[],
             "ridp_documents"=>[],
             "verification_type_history_elements"=>[],
             "lawful_presence_determination"=>
              {"vlp_verified_at"=>nil,
               "vlp_authority"=>nil,
               "vlp_document_id"=>nil,
               "citizen_status"=>"us_citizen",
               "citizenship_result"=>nil,
               "qualified_non_citizenship_result"=>nil,
               "aasm_state"=>"verification_pending",
               "ssa_responses"=>[],
               "ssa_requests"=>[],
               "vlp_responses"=>[],
               "vlp_requests"=>[]},
             "local_residency_responses"=>[],
             "local_residency_requests"=>[]},
           "resident_role"=>nil,
           "individual_market_transitions"=>[],
           "verification_types"=>[],
           "broker_role"=>nil,
           "user"=>{},
           "addresses"=>
            [{"has_fixed_address"=>true,
              "kind"=>"home",
              "address_1"=>"1123 Awesome Street NE",
              "address_2"=>"#123",
              "address_3"=>"",
              "city"=>"Washington",
              "county"=>"Hampden",
              "state"=>"DC",
              "zip"=>"01001",
              "country_name"=>"United States of America"},
             {"has_fixed_address"=>true,
              "kind"=>"home",
              "address_1"=>"1124 Awesome Street NE",
              "address_2"=>"#124",
              "address_3"=>"",
              "city"=>"Washington",
              "county"=>"Hampden",
              "state"=>"DC",
              "zip"=>"01001",
              "country_name"=>"United States of America"}],
           "emails"=>
            [{"kind"=>"home", "address"=>"example7@example.com"},
             {"kind"=>"home", "address"=>"example8@example.com"}],
           "phones"=>
            [{"kind"=>"home",
              "country_code"=>"",
              "area_code"=>"202",
              "number"=>"1111123",
              "extension"=>"13",
              "primary"=>nil,
              "full_phone_number"=>"202111112313"},
             {"kind"=>"home",
              "country_code"=>"",
              "area_code"=>"202",
              "number"=>"1111124",
              "extension"=>"14",
              "primary"=>nil,
              "full_phone_number"=>"202111112414"}],
           "documents"=>[],
           "timestamp"=>
            {"created_at"=>"2021-09-15T17:46:11.562+00:00",
             "modified_at"=>"2021-09-15T17:46:11.562+00:00"}},
         "timestamp"=>
          {"created_at"=>"2021-09-15T17:46:11.649+00:00",
           "modified_at"=>"2021-09-15T17:46:11.649+00:00"}}],
      "timestamp"=>
       {"created_at"=>"2021-09-15T17:46:11.650+00:00",
        "modified_at"=>"2021-09-15T17:46:11.663+00:00"}
      }
  end

  let(:account_params) do
    {
      :hbxid_c=>"a95878c60b424759935bca542832d5b7",
      :name=>"John Jacob",
      :email1=>"example1@example.com",
      :dob_c=>"1981-09-14",
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
      :hbxid_c=>"a95878c60b424759935bca542832d5b7",
      :first_name=>"John",
      :last_name=>"Jacob",
      :phone_mobile=>"2021030404",
      :email1=>"example1@example.com"
    }
  end


  describe '#find_contacts_by_account' do
    let(:family_member) do
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
      }
    end

    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(payload: account_params)
      account['id']
    end

    let(:contact) do
      SugarCRM::Services::Connection.new.create_contact_for_account(payload: contact_params.merge('account.id': account_id))
    end

    let(:contacts) do
      contact
      contacts = SugarCRM::Services::Connection.new.find_contacts_by_account(account_id)
      contacts['records']
    end

    let(:result) do
      VCR.use_cassette('find_contacts_by_account_family_upsert') do
        described_class.new.match_family_member_to_contact(
          family_member: family_member, contacts: contacts
        )
      end   
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end
  end

  describe '#update_existing_contact' do
    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(payload: account_params)
      account['id']
    end

    let(:family_member) do
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
      }
    end

    let(:contact_id) do
      contact = SugarCRM::Services::Connection.new.create_contact_for_account(payload: contact_params.merge('account.id': account_id))
      contact['id']
    end

    let(:result) do
      VCR.use_cassette('update_existing_contact_family_upsert') do
        described_class.new.update_existing_contact(
          id: contact_id,
          params: family_member
        )
      end  
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end
  end

  describe '#create_contact' do
    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(payload: account_params)
      account['id']
    end

    let(:family_member) do
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
      }
    end

    let(:result) do
      VCR.use_cassette('create_contact_family_upsert') do
        described_class.new.create_contact(
          account_id: account_id,
          params: family_member
        )
      end
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end

    it "passes name" do #! this may not be right
      expect(result.value!['accounts']['name']).to eql('John Jacob')
    end
  end

  describe '#call' do
    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(payload: account_params)
      account['id']
    end

    let(:contact) do
      SugarCRM::Services::Connection.new.create_contact_for_account(payload: contact_params.merge('account.id': account_id))
    end

    context "with an existing family_member and contact" do
      let(:result) do
        VCR.use_cassette('family_upsert_call_with_existing_family_and_contact') do
          contact
          described_class.new.call(
            payload: payload
          )
        end
      end
  
      it 'is a success' do
        expect(result.success?).to be_truthy
      end
  
      it "the value is a hash" do
        expect(result.value!).to eql("Successful family update")
      end
    end

    context "without an existing family and contact" do
      let(:contact) do
        SugarCRM::Services::Connection.new.create_contact_for_account(
          account_id: account_id,
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
      end

      let(:result) do 
        VCR.use_cassette('family_upsert_call_without_family') do
          described_class.new.call(
            payload: payload
          )
        end
      end

      it 'is a success' do
        expect(result.success?).to be_truthy
      end

      it "the value is a hash" do
        expect(result.value!).to eql("Successful family update")
      end
    end
  end
end