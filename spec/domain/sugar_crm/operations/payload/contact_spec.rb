# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::Payload::Contact do

  let(:payload) do
    {
      "hbx_id" => "a95888d60b424759935bca542832d5b7",
      "person" =>
    {
      "hbx_id" => "a95878c60b424759935bca542832d5b7",
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
         "modified_at" => "2021-09-15T17:46:11.434+00:00"}
    }
    }
  end

  let(:relationship_to_primary) { "Self" }


  subject do
    described_class.new
  end

  context "Valid Contact" do
    let(:result) {subject.call(payload.deep_symbolize_keys, relationship_to_primary)}


    it "returns a success response" do
      expect(result).to be_success
    end
  end

  context "Invalid Contact" do
    let(:result) {subject.call(payload.deep_symbolize_keys.merge(hbx_id: nil), relationship_to_primary)}


    it "returns a failure response" do
      expect(result).to_not be_success
    end
  end

  context "Values are present" do
    let(:result_value) {subject.call(payload.deep_symbolize_keys, relationship_to_primary).value!}

    it "should include relationship_c key" do
      expect(result_value[:relationship_c]).to eql("Self")
    end

    it "should include first_name key" do
      expect(result_value[:first_name]).to eql("Doe")
    end

    it "should include last_name key" do
      expect(result_value[:last_name]).to eql("John")
    end

    it "should include phone_mobile key" do
      expect(result_value[:phone_mobile]).to eql("(202) 111-1119")
    end

    it "should include email1 key" do
      expect(result_value[:email1]).to eql("example3@example.com")
    end

    it "should include birthdate key" do
      expect(result_value[:birthdate]).to eql("1972-04-04")
    end
  end
end
