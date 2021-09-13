# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::PrimaryUpsert do

  describe '#call' do
    context "with an existing account and contact" do
      let(:account_id) do
        account = SugarCRM::Services::Connection.new.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        account['id']
      end
  
      let(:contact) do
        SugarCRM::Services::Connection.new.create_contact_for_account(
          account_id: account_id,
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
      end
  
      let(:result) do 
        VCR.use_cassette('primary_upsert_call_with_existing_account_and_contact') do
          contact
          described_class.new.call(
            payload: {
              hbx_id: '123',
              first_name: 'Tim',
              last_name: 'Jacob'
            }
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
            payload: {
              hbx_id: '123',
              first_name: 'Tim',
              last_name: 'Jacob'
            }
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
          response = subject.find_existing_account(hbx_id: "zzzz435g")
          expect(response.failure?).to be_truthy
        end
      end
    end

    context "with an existing account" do
      let(:hbx_id) do
        VCR.use_cassette('create_account_for_primary_upsert') do
          account = SugarCRM::Services::Connection.new.create_account(
            hbx_id: '123',
            first_name: 'John',
            last_name: 'Jacob'
          )
          account['hbxid_c']
        end
      end

      let(:result) { subject.find_existing_account(hbx_id: hbx_id) }

      it "returns a success" do
        VCR.use_cassette('find_existing_account_for_primary_upsert') do 
          expect(result.success?).to be_truthy
        end
      end
     
      it "result is the account id" do
        VCR.use_cassette('find_existing_account_for_primary_upsert') do 
          expect(result.value!).to be_an_instance_of(String)
        end
      end
    end
  end

  describe "#create_account_and_contact" do
    subject do
      described_class.new
    end

    let(:result) do 
      VCR.use_cassette('create_account_and_contact_for_primary_upsert') do
        subject.create_account_and_contact(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
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

  describe "#update_account" do
    let(:hbx_id) do
      account = SugarCRM::Services::Connection.new.create_account(
        hbx_id: '123',
        first_name: 'John',
        last_name: 'Jacob'
      )
      account['hbxid_c']
    end

    let(:result) do 
      VCR.use_cassette('update_account_for_primary_upsert') do
        subject.update_account(
          hbx_id: hbx_id,
          first_name: 'Tim',
          last_name: 'Robinson'
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

  describe "#update_contact" do 
    let(:account_id) do
      account = SugarCRM::Services::Connection.new.create_account(
        hbx_id: '123',
        first_name: 'John',
        last_name: 'Jacob'
      )
      account['id']
    end

    let(:contact) do
      SugarCRM::Services::Connection.new.create_contact_for_account(
        account_id: account_id,
        hbx_id: '123',
        first_name: 'John',
        last_name: 'Jacob'
      )
    end

    let(:result) do 
      VCR.use_cassette('update_contact_for_primary_upsert') do
        contact
        subject.update_contact(
          hbx_id: '123',
          first_name: 'Tim',
          last_name: 'Robinson'
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