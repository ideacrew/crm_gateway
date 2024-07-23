# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::Families::Create, dbclean: :after_each do

  include_context 'sugar account and contacts'

  let(:after_save_updated_at) { DateTime.now.to_s }
  let(:job) { FactoryBot.create(:transmittable_job) }
  let(:address_1) { cv3_family[:family_members].first[:person][:addresses].first[:address_1] }
  let(:city) { cv3_family[:family_members].first[:person][:addresses].first[:city] }
  let(:zip) { cv3_family[:family_members].first[:person][:addresses].first[:zip] }
  let(:email) { cv3_family[:family_members].first[:person][:emails].first[:address] }
  let(:phone_number) { cv3_family[:family_members].first[:person][:phones].first[:full_phone_number] }
  let(:name) { cv3_family[:family_members].first[:person][:person_name][:full_name] }

  describe "Success" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: cv3_family,
                                           inbound_after_updated_at: after_save_updated_at,
                                           job: job
                                         })
    end

    context "with valid params" do

      it "returns a success response" do
        expect(@result).to be_success
      end

      it "returns a family" do
        expect(@result.success).to be_a(Family)
      end
    end

    context "outbound payload" do

      before do
        @outbound_payload = @result.success.outbound_account_cv_hash
      end

      it "has addresses" do
        expect(@outbound_payload[:billing_address_street]).to eql(address_1)
        expect(@outbound_payload[:billing_address_city]).to eql(city)
        expect(@outbound_payload[:billing_address_postalcode]).to eql(zip)
      end

      it "has emails" do
        expect(@outbound_payload[:email1]).to eql(email)
      end

      it "has phones" do
        expect(@outbound_payload[:phone_office]).to eql(phone_number)
      end

      it "has name" do
        expect(@outbound_payload[:name]).to eql(name)
      end

      it "has contacts" do
        expect(@outbound_payload[:contacts]).to be_truthy
      end
    end
  end

  describe "Failure" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: {},
                                           after_updated_at: after_save_updated_at
                                         })
    end

    context "with invalid params" do

      it "returns a failure response" do
        expect(@result.failure?).to be_truthy
      end

      it "returns a failure message" do
        expect(@result.failure).to eql("Inbound family cv payload not present")
      end
    end
  end
end