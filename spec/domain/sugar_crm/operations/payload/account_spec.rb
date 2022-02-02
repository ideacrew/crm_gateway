# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::Payload::Account do

    let(:account_params) do
        {
          :hbxid_c => "a95878c60b424759935bca542832d5b7",
          :name => "John Jacob",
          :email1 => "example1@example.com",
          :dob_c => "1981-09-14",
          :billing_address_street => "1111 Awesome Street NE",
          :billing_address_street_2 => "#111",
          :billing_address_street_3 => "",
          :billing_address_street_4 => nil,
          :billing_address_city => "Washington",
          :billing_address_postalcode => "01001",
          :billing_address_state => "DC",
          :phone_office => "2021030404",
          :ssn => "768252862"
        }
      end
  subject do
    described_class.new
  end

    context "Valid Account" do
      #binding.irb
      let(:result) {subject.call(account_params.deep_symbolize_keys.merge('hbx_id': 'a95878c60b424759935bca542832d5b7"'))}

      it "returns a success response" do
        expect(result).to be_success
      end
    end

    context "Invalid Phone Number" do
      
        let(:result) {subject.call(account_params.deep_symbolize_keys.merge('hbx_id': nil))}

      it "returns a failure response" do
        result
        expect(result).to_not be_success
      end
    end
end