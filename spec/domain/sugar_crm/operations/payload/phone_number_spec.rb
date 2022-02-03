# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::Payload::PhoneNumber do

  let(:params) do
    {
      "hbx_id" => "a95878c60b424759935bca542832d5b7",
      "family_members" =>
         [
          {
            "hbx_id" => "a95878c60b424759935bca542832d5b7",
            "is_primary_applicant" => true,
            "is_consent_applicant" => false,
            "is_coverage_applicant" => true,
            "is_active" => true,
            "person" =>
            {"hbx_id" => "a95878c60b424759935bca542832d5b7",
             "person_name" =>
              {"first_name" => "Doe",
               "middle_name" => nil,
               "last_name" => "John",
               "name_sfx" => nil,
               "name_pfx" => nil,
               "full_name" => "Doe John",
               "alternate_name" => nil},
             "person_demographics" =>
              {"ssn" => "775481172",
               "no_ssn" => false,
               "gender" => "male",
               "dob" => "1972-04-04",
               "date_of_death" => nil,
               "dob_check" => nil,
               "is_incarcerated" => false,
               "ethnicity" => nil,
               "race" => nil,
               "tribal_id" => nil,
               "language_code" => nil},
             "person_health" =>
              {"is_tobacco_user" => "unknown", "is_physically_disabled" => nil},
             "no_dc_address" => false,
             "no_dc_address_reason" => nil,
             "is_homeless" => false,
             "is_temporarily_out_of_state" => false,
             "age_off_excluded" => false,
             "is_applying_for_assistance" => nil,
             "is_active" => true,
             "is_disabled" => nil,
             "person_relationships" =>
              [{"relative" =>
                 {"hbx_id" => "a95878c60b424759935bca542832d5b7",
                  "first_name" => "Doe",
                  "middle_name" => nil,
                  "last_name" => "John",
                  "ssn" => "768252862",
                  "no_ssn" => false,
                  "dob" => "1972-04-04",
                  "gender" => "male"},
                "kind" => "self"},
               {"relative" =>
                 {"hbx_id" => "4bb301e2936b46518705a2acc709eed4",
                  "first_name" => "John",
                  "middle_name" => nil,
                  "last_name" => "Smith1",
                  "ssn" => "768252862",
                  "no_ssn" => false,
                  "dob" => "1972-04-04",
                  "gender" => "male"},
                "kind" => "spouse"},
               {"relative" =>
                 {"hbx_id" => "b7bfbc6b58f340169de7f0772e88230f",
                  "first_name" => "John",
                  "middle_name" => nil,
                  "last_name" => "Smith2",
                  "ssn" => "740491753",
                  "no_ssn" => false,
                  "dob" => "1972-04-04",
                  "gender" => "male"},
                "kind" => "child"}],
             "consumer_role" => nil,
             "resident_role" => nil,
             "individual_market_transitions" => [],
             "verification_types" => [],
             "broker_role" => nil,
             "user" => {},
             "addresses" =>
              [{"has_fixed_address" => true,
                "kind" => "home",
                "address_1" => "1119 Awesome Street NE",
                "address_2" => "#119",
                "address_3" => "",
                "city" => "Washington",
                "county" => "Hampden",
                "state" => "DC",
                "zip" => "01001",
                "country_name" => "United States of America"},
               {"has_fixed_address" => true,
                "kind" => "home",
                "address_1" => "1120 Awesome Street NE",
                "address_2" => "#120",
                "address_3" => "",
                "city" => "Washington",
                "county" => "Hampden",
                "state" => "DC",
                "zip" => "01001",
                "country_name" => "United States of America"}],
             "emails" =>
              [{"kind" => "home", "address" => "example3@example.com"},
               {"kind" => "home", "address" => "example4@example.com"}],
             "phones" =>
              [{"kind" => "home",
                "country_code" => "",
                "area_code" => "202",
                "number" => "1111119",
                "extension" => "9",
                "primary" => nil,
                "full_phone_number" => "20211111199"},
               {"kind" => "home",
                "country_code" => "",
                "area_code" => "202",
                "number" => "1111120",
                "extension" => "10",
                "primary" => nil,
                "full_phone_number" => "202111112010"}],
             "documents" => [],
             "timestamp" =>
              {"created_at" => "2021-09-15T17:46:11.434+00:00",
               "modified_at" => "2021-09-15T17:46:11.434+00:00"}},
            "timestamp" =>
            {"created_at" => "2021-09-15T17:46:11.649+00:00",
             "modified_at" => "2021-09-15T17:46:11.649+00:00"}
          },
          {"hbx_id" => "b7bfbc6b58f340169de7f0772e88230f",
           "is_primary_applicant" => false,
           "is_consent_applicant" => false,
           "is_coverage_applicant" => true,
           "is_active" => true,
           "person" =>
            {"hbx_id" => "b7bfbc6b58f340169de7f0772e88230f",
             "person_name" =>
              {"first_name" => "John",
               "middle_name" => nil,
               "last_name" => "Smith2",
               "name_sfx" => nil,
               "name_pfx" => nil,
               "full_name" => "John Smith2",
               "alternate_name" => nil},
             "person_demographics" =>
              {"ssn" => "740491753",
               "no_ssn" => false,
               "gender" => "male",
               "dob" => "1972-04-04",
               "date_of_death" => nil,
               "dob_check" => nil,
               "is_incarcerated" => true,
               "ethnicity" => nil,
               "race" => nil,
               "tribal_id" => nil,
               "language_code" => nil},
             "person_health" =>
              {"is_tobacco_user" => "unknown", "is_physically_disabled" => nil},
             "no_dc_address" => false,
             "no_dc_address_reason" => nil,
             "is_homeless" => false,
             "is_temporarily_out_of_state" => false,
             "age_off_excluded" => false,
             "is_applying_for_assistance" => nil,
             "is_active" => true,
             "is_disabled" => nil,
             "person_relationships" => [],
             "consumer_role" =>
              {"five_year_bar" => false,
               "requested_coverage_start_date" => "2021-09-15",
               "aasm_state" => "unverified",
               "is_applicant" => true,
               "birth_location" => nil,
               "marital_status" => nil,
               "is_active" => true,
               "is_applying_coverage" => true,
               "bookmark_url" => nil,
               "admin_bookmark_url" => nil,
               "contact_method" => "mail",
               "language_preference" => "English",
               "is_state_resident" => true,
               "identity_validation" => "na",
               "identity_update_reason" => nil,
               "application_validation" => "na",
               "application_update_reason" => nil,
               "identity_rejected" => false,
               "application_rejected" => false,
               "documents" => [],
               "vlp_documents" => [],
               "ridp_documents" => [],
               "verification_type_history_elements" => [],
               "lawful_presence_determination" =>
                {"vlp_verified_at" => nil,
                 "vlp_authority" => nil,
                 "vlp_document_id" => nil,
                 "citizen_status" => "us_citizen",
                 "citizenship_result" => nil,
                 "qualified_non_citizenship_result" => nil,
                 "aasm_state" => "verification_pending",
                 "ssa_responses" => [],
                 "ssa_requests" => [],
                 "vlp_responses" => [],
                 "vlp_requests" => []},
               "local_residency_responses" => [],
               "local_residency_requests" => []},
             "resident_role" => nil,
             "individual_market_transitions" => [],
             "verification_types" => [],
             "broker_role" => nil,
             "user" => {},
             "addresses" =>
              [{"has_fixed_address" => true,
                "kind" => "home",
                "address_1" => "1123 Awesome Street NE",
                "address_2" => "#123",
                "address_3" => "",
                "city" => "Washington",
                "county" => "Hampden",
                "state" => "DC",
                "zip" => "01001",
                "country_name" => "United States of America"},
               {"has_fixed_address" => true,
                "kind" => "home",
                "address_1" => "1124 Awesome Street NE",
                "address_2" => "#124",
                "address_3" => "",
                "city" => "Washington",
                "county" => "Hampden",
                "state" => "DC",
                "zip" => "01001",
                "country_name" => "United States of America"}],
             "emails" =>
              [{"kind" => "home", "address" => "example7@example.com"},
               {"kind" => "home", "address" => "example8@example.com"}],
             "phones" =>
              [{"kind" => "home",
                "country_code" => "",
                "area_code" => "202",
                "number" => "1111123",
                "extension" => "13",
                "primary" => nil,
                "full_phone_number" => "202111112313"},
               {"kind" => "home",
                "country_code" => "",
                "area_code" => "202",
                "number" => "1111124",
                "extension" => "14",
                "primary" => nil,
                "full_phone_number" => "202111112414"}],
             "documents" => [],
             "timestamp" =>
              {"created_at" => "2021-09-15T17:46:11.562+00:00",
               "modified_at" => "2021-09-15T17:46:11.562+00:00"}},
           "timestamp" =>
            {"created_at" => "2021-09-15T17:46:11.649+00:00",
             "modified_at" => "2021-09-15T17:46:11.649+00:00"}}
  ],
      "timestamp" =>
         {"created_at" => "2021-09-15T17:46:11.650+00:00",
          "modified_at" => "2021-09-15T17:46:11.663+00:00"}
    }
  end
  subject do
    described_class.new
  end

  context "Valid Phone Number" do
    let(:symbolized_params) {params.deep_symbolize_keys}
    let(:result) {subject.call(symbolized_params[:family_members].first[:person][:phones])}

    it "returns a success response" do

      #params
      #symbolized_params
      expect(result).to be_success
    end
  end

  context "Invalid Phone Number" do

    let(:result) {subject.call(params.deep_symbolize_keys[:family_members].first[:person].merge(phones: []))}

    it "returns a failure response" do
      result
      expect(result).to_not be_success
    end
  end
end