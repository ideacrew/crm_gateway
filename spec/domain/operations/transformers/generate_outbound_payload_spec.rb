# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::Transformers::GenerateOutboundPayload, dbclean: :after_each do

  include_context 'sugar account and contacts'

  let(:family) { FactoryBot.create(:family) }

  let(:address_1) { cv3_family[:family_members].first[:person][:addresses].first[:address_1] }
  let(:city) { cv3_family[:family_members].first[:person][:addresses].first[:city] }
  let(:zip) { cv3_family[:family_members].first[:person][:addresses].first[:zip] }
  let(:email) { cv3_family[:family_members].first[:person][:emails].first[:address] }
  let(:phone_number) { cv3_family[:family_members].first[:person][:phones].first[:full_phone_number] }
  let(:name) { cv3_family[:family_members].first[:person][:person_name][:full_name] }

  describe "Success" do

    before do
      family.inbound_payload = cv3_family.to_json
      family.save
      family.reload
      family_entity = family.inbound_family_entity
      @result = described_class.new.call(family_entity)
    end

    it "returns a success response" do
      expect(@result).to be_success
    end

    it "has addresses" do
      expect(@result.success[:billing_address_street]).to eql(address_1)
      expect(@result.success[:billing_address_city]).to eql(city)
      expect(@result.success[:billing_address_postalcode]).to eql(zip)
    end

    it "has emails" do
      expect(@result.success[:email1]).to eql(email)
    end

    it "has phones" do
      expect(@result.success[:phone_office]).to eql(phone_number)
    end

    it "has name" do
      expect(@result.success[:name]).to eql(name)
    end

    it "has contacts" do
      expect(@result.success[:contacts]).to be_truthy
    end
  end

  describe "Failure" do

    before do
      @result = described_class.new.call({})
    end

    context "with invalid params" do

      it "returns a failure response" do
        expect(@result.failure?).to be_truthy
      end
    end
  end
end