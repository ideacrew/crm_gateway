# frozen_string_literal: true

require 'rails_helper'

include Dry::Monads[:result]

RSpec.describe SugarCRM::Operations::PrimaryUpsert do
  describe '#call' do
    let(:payload) { { hbx_id: 'x' } }

    let(:a_successful_response) do
      body = {
        records: [
          id: 'x'
        ]
      }

      OAuth2::Response.new(
        Faraday::Response.new(url: 'url',
          body: body.to_json,
          response_headers: { 'Content-Type': 'application/json'}
        ),
        { parse: :json }
      )
    end

    let(:an_empty_response) do
      body = {
        records: []
      }

      OAuth2::Response.new(
        Faraday::Response.new(url: 'url',
          body: body.to_json,
          response_headers: { 'Content-Type': 'application/json'}
        ),
        { parse: :json }
      )
    end

    let(:a_successful_upsert) do
      OAuth2::Response.new(
        Faraday::Response.new(url: 'url',
          body: { id: 'x' }.to_json,
          response_headers: { 'Content-Type': 'application/json'}
        ),
        { parse: :json }
      )
    end
    
    subject do
      described_class.new
    end

    before do
      allow(subject).to receive(:response_call).and_yield
      allow(subject).to receive(:payload_to_account_params).and_return({})
      allow(subject).to receive(:payload_to_contact_params).and_return({})
    end

    context "of existing account" do
      before do
        allow(subject).to receive(:find_existing_account).and_return(Success(a_successful_response))
        allow(subject).to receive(:update_account).and_return(Success(a_successful_upsert))
      end

      context "of existing contact" do
        before do
          allow(subject).to receive(:find_existing_contact).and_return(Success(a_successful_response))
          allow(subject).to receive(:update_contact).and_return(Success(a_successful_upsert))
        end

        it "returns the correct set of steps and responses" do
          expect(subject.call(payload: payload).value!.map(&:keys).flatten).to contain_exactly(:find_existing_account, :update_account, :find_existing_contact, :update_contact)
        end
      end

      context "without an existing contact" do
        before do
          allow(subject).to receive(:find_existing_contact).and_return(Failure(an_empty_response))
          allow(subject).to receive(:create_contact).and_return(Success(a_successful_upsert))
        end

        it "returns the correct set of steps and responses" do
          expect(subject.call(payload: payload).value!.map(&:keys).flatten).to contain_exactly(:find_existing_account, :update_account, :find_existing_contact, :create_contact)
        end
      end
    end

    context "of no existing account" do
      before do
        allow(subject).to receive(:find_existing_account).and_return(Failure(an_empty_response))
        allow(subject).to receive(:create_account).and_return(Success(a_successful_upsert))
      end

      context "of existing contact" do
        before do
          allow(subject).to receive(:find_existing_contact).and_return(Success(a_successful_response))
          allow(subject).to receive(:update_contact).and_return(Success(a_successful_upsert))
        end

        it "returns the correct set of steps and responses" do
          expect(subject.call(payload: payload).value!.map(&:keys).flatten).to contain_exactly(:find_existing_account, :create_account, :find_existing_contact, :update_contact)
        end
      end

      context "without an existing contact" do
        before do
          allow(subject).to receive(:find_existing_contact).and_return(Failure(an_empty_response))
          allow(subject).to receive(:create_contact).and_return(Success(a_successful_upsert))
        end

        it "returns the correct set of steps and responses" do
          expect(subject.call(payload: payload).value!.map(&:keys).flatten).to contain_exactly(:find_existing_account, :create_account, :find_existing_contact, :create_contact)
        end
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
          payload: described_class.new.payload_to_account_params(payload)
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

  describe "#create_account_and_contact" do
    subject do
      described_class.new
    end

    let(:result) do
      VCR.use_cassette('create_account_and_contact_for_primary_upsert') do
        subject.create_account_and_contact(payload)
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
        payload: subject.payload_to_account_params(payload)
      )
    end

    let(:result) do
      VCR.use_cassette('update_account_for_primary_upsert') do
        account
        subject.update_account(subject.payload_to_account_params(payload))
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
        payload: subject.payload_to_account_params(payload)
      )
      account['id']
    end

    let(:contact) do
      SugarCRM::Services::Connection.new.create_contact_for_account(
        payload: subject.payload_to_contact_params(
          payload.merge('account.id': account_id)
        )
      )
    end

    let(:result) do
      VCR.use_cassette('update_contact_for_primary_upsert') do
        contact
        subject.update_contact(payload)
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