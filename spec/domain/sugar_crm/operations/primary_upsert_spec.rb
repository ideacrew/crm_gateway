# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::PrimaryUpsert do
  let(:hbx_id) { 'aa918614ae014d42bb8547a1ae5734e1' }

  let(:payload) do
    {
      :hbx_id => hbx_id,
      :person_name =>
       {:first_name => "John",
        :middle_name => nil,
        :last_name => "Smith1",
        :name_sfx => nil,
        :name_pfx => nil,
        :full_name => "John Smith1",
        :alternate_name => nil},
      :person_demographics =>
       {:ssn => "775481172",
        :no_ssn => false,
        :gender => "male",
        :dob => "1981-09-14",
        :date_of_death => nil,
        :dob_check => nil,
        :is_incarcerated => true,
        :ethnicity => nil,
        :race => nil,
        :tribal_id => nil,
        :language_code => nil},
      :person_health => {:is_tobacco_user => "unknown", :is_physically_disabled => nil},
      :is_active => true,
      :is_disabled => false,
      :no_dc_address => false,
      :no_dc_address_reason => nil,
      :is_homeless => false,
      :is_temporarily_out_of_state => false,
      :age_off_excluded => false,
      :is_applying_for_assistance => nil,
      :person_relationships => [],
      :consumer_role =>
       {:five_year_bar => false,
        :requested_coverage_start_date => "15-Sep-2021",
        :aasm_state => "unverified",
        :is_applicant => true,
        :birth_location => nil,
        :marital_status => nil,
        :is_active => true,
        :is_applying_coverage => true,
        :bookmark_url => nil,
        :admin_bookmark_url => nil,
        :contact_method => "mail",
        :language_preference => "English",
        :is_state_resident => true,
        :identity_validation => "na",
        :identity_update_reason => nil,
        :application_validation => "na",
        :application_update_reason => nil,
        :identity_rejected => false,
        :application_rejected => false,
        :documents => [],
        :vlp_documents => [],
        :ridp_documents => [],
        :verification_type_history_elements => [],
        :lawful_presence_determination =>
         {:vlp_verified_at => nil,
          :vlp_authority => nil,
          :vlp_document_id => nil,
          :citizen_status => "us_citizen",
          :citizenship_result => nil,
          :qualified_non_citizenship_result => nil,
          :aasm_state => "verification_pending",
          :ssa_responses => [],
          :ssa_requests => [],
          :vlp_responses => [],
          :vlp_requests => []},
        :local_residency_responses => [],
        :local_residency_requests => []},
      :resident_role => nil,
      :individual_market_transitions => [],
      :verification_types => [],
      :user => nil,
      :broker_role => nil,
      :addresses =>
       [{:kind => "home",
         :address_1 => "1111 Awesome Street NE",
         :address_2 => "#111",
         :address_3 => "",
         :city => "Washington",
         :county => "Hampden",
         :state => "DC",
         :zip => "01001",
         :country_name => "United States of America",
         :has_fixed_address => true},
        {:kind => "home",
         :address_1 => "1112 Awesome Street NE",
         :address_2 => "#112",
         :address_3 => "",
         :city => "Washington",
         :county => "Hampden",
         :state => "DC",
         :zip => "01001",
         :country_name => "United States of America",
         :has_fixed_address => true}],
      :phones =>
       [{:kind => "home",
         :country_code => "",
         :area_code => "202",
         :number => "1030404",
         :extension => "",
         :primary => nil,
         :full_phone_number => "2021030404"}],
      :emails =>
       [{:kind => "home", :address => "example1@example.com"},
        {:kind => "home", :address => "example2@example.com"}],
      :documents => [],
      :timestamp =>
       {:created_at => "2021-09-15 10:51:46 -0400",
        :modified_at => "2021-09-15 10:51:46 -0400"}
    }
  end

  describe '#call' do
    context "with an existing account and contact" do
      let(:account_id) do
        account = SugarCRM::Services::Connection.new.create_account(
          payload: SugarCRM::Operations::Payload::Account.new.call(payload)
        )
        account['id']
      end

      let(:contact) do
        SugarCRM::Services::Connection.new.create_contact_for_account(
          payload: SugarCRM::Operations::Payload::Contact.new.call(payload.merge('account.id': account_id))
        )
      end

      let(:result) do
        VCR.use_cassette('primary_upsert_call_with_existing_account_and_contact') do
          contact
          payload[:person_name].merge!(first_name: "Johnathan")
          described_class.new.call(
            payload: payload
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

    context "without an existing account and contact" do
      let(:result) do
        VCR.use_cassette('primary_upsert_call') do
          described_class.new.call(
            payload: payload
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
  end

  describe '#find_existing_account' do
    subject do
      described_class.new
    end

    context "without an existing account" do
      it "returns a failure" do
        VCR.use_cassette('find_non_existing_account_for_primary_upsert') do
          response = subject.find_existing_account(hbx_id: 'zzjkdlf')
          expect(response.failure?).to be_truthy
        end
      end
    end

    context "with an existing account" do
      let(:account) do
        account = SugarCRM::Services::Connection.new.create_account(
          payload: SugarCRM::Operations::Payload::Account.new.call(payload)
        )
        account['hbxid_c']
      end

      let(:result) do
        VCR.use_cassette('create_account_for_primary_upsert') do
          account
          subject.find_existing_account(hbx_id: hbx_id)
        end
      end

      it "returns a success" do
        expect(result.success?).to be_truthy
      end

      it "result is the account id" do
        expect(result.value!).to be_an_instance_of(String)
      end
    end
  end

  describe "#create_account" do
    subject do
      described_class.new
    end

    let(:result) do
      VCR.use_cassette('create_account_for_primary_upsert') do
        subject.create_account(payload)
      end
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end
  end

  describe "#update_account" do
    subject do
      described_class.new.tap do |instance|
        instance.hbx_id = hbx_id
      end
    end

    let(:account) do
      SugarCRM::Services::Connection.new.create_account(
        payload: SugarCRM::Operations::Payload::Account.new.call(payload)
      )
    end

    let(:result) do
      VCR.use_cassette('update_account_for_primary_upsert') do
        account
        subject.update_account(account['id'], SugarCRM::Operations::Payload::Account.new.call(payload))
      end
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end
  end

  describe "#update_contact" do
    subject do
      described_class.new.tap do |instance|
        instance.hbx_id = hbx_id
      end
    end

    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(
        payload: SugarCRM::Operations::Payload::Account.new.call(payload)
      )
      account['id']
    end

    let(:contact) do
      SugarCRM::Services::Connection.new.create_contact_for_account(
        payload: SugarCRM::Operations::Payload::Contact.new.call(
          payload.merge('account.id': account_id)
        )
      )
    end

    let(:result) do
      VCR.use_cassette('update_contact_for_primary_upsert') do
        contact
        subject.update_contact(contact['id'], payload)
      end
    end

    it 'is a success' do
      expect(result.success?).to be_truthy
    end

    it "the value is a hash" do
      expect(result.value!).to be_an_instance_of(Hash)
    end
  end
end