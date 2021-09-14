# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Services::Connection do
  describe 'self.connection' do
    it 'connects to SugarCRM and gets an access_token' do
      VCR.use_cassette('connection') do
        expect(subject.class.connection).to be_an_instance_of(OAuth2::AccessToken)
      end
    end
  end

  describe '#create_account' do
    let(:response) do
      VCR.use_cassette('create_account') do
        subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
      end
    end

    it 'creates an account' do
      expect(response).to be_an_instance_of(Hash)
    end

    it 'has the correct name' do
      expect(response['name']).to eql('John Jacob')
    end
  end

  describe '#create_contact_for_account' do
    let(:response) do
      VCR.use_cassette('create_contact') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )

        subject.create_contact_for_account(
          account_id: account['id'],
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
      end
    end

    it 'creates a contact with the correct name' do
      expect(response['name']).to eql('John Jacob')
    end
  end

  describe '#find_account_by_hbx_id' do
    let(:response) do
      VCR.use_cassette('find_account_by_name') do
        subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.find_account_by_hbx_id('123')
      end
    end

    it 'finds the correct account' do
      expect(response).to be_an_instance_of(String)
    end
  end

  describe '#find_contacts_by_account' do
    let(:response) do
      VCR.use_cassette('find_contacts_by_account') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.create_contact_for_account(
          account_id: account['id'],
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        response = subject.find_account_by_hbx_id('123')
        subject.find_contacts_by_account(
          response
        )
      end
    end

    it 'finds the correct contacts' do
      expect(response['records'].first['name']).to eql('John Jacob')
    end
  end

  describe '#update_account' do
    let(:response) do
      VCR.use_cassette('update_account') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.update_account(
          hbx_id: '123',
          first_name: 'Tim',
          last_name: 'Robinson'
        )
      end
    end

    it "updates the account" do
      expect(response['name']).to eql('Tim Robinson')
    end

  end

  describe '#update_contact' do
    let(:response) do
      VCR.use_cassette('update_contact') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        contact = subject.create_contact_for_account(
          account_id: account['id'],
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.update_contact(
          id: contact['id'],
          first_name: 'Tim',
          last_name: 'Robinson'
        )
      end
    end

    it "should update contact" do 
      expect(response['name']).to eql('Tim Robinson')
    end
  end

  describe '#update_contact_by_hbx_id' do
    let(:response) do
      VCR.use_cassette('update_contact_by_hbx_id') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.create_contact_for_account(
          account_id: account['id'],
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.update_contact_by_hbx_id(
          hbx_id: '123',
          first_name: 'Tim',
          last_name: 'Robinson'
        )
      end
    end

    it "should update contact" do 
      expect(response['name']).to eql('Tim Robinson')
    end
  end

  describe '#find_contact_by_hbx_id' do 

    let(:response) do
      VCR.use_cassette('find_contact_by_hbx_id') do
        account = subject.create_account(
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.create_contact_for_account(
          account_id: account['id'],
          hbx_id: '123',
          first_name: 'John',
          last_name: 'Jacob'
        )
        subject.find_contact_by_hbx_id('123')
      end
    end

    it 'finds contact by hbx_id' do
      expect(response).to be_an_instance_of(String)
    end
  end

  describe "::refresh_token" do
    it "refreshes the access token" do
      VCR.use_cassette("refresh_token") do
        expect(described_class.refresh_token).to be_an_instance_of(OAuth2::AccessToken)
      end
    end
  end
end