# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Services::Connection do
  let(:hbx_id) { 'aa918614ae014d42bb8547a1ae5734e1' }

  let(:account_params) do
    {
      :hbxid_c=>"aa918614ae014d42bb8547a1ae5734e1",
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
      :hbxid_c=>"aa918614ae014d42bb8547a1ae5734e1",
      :first_name=>"John",
      :last_name=>"Jacob",
      :phone_mobile=>"2021030404",
      :email1=>"example1@example.com"
    }
  end

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
        subject.create_account(payload: account_params)
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
        account = subject.create_account(payload: account_params)
        subject.create_contact_for_account(payload: contact_params.merge('account.id': account['id']))
      end
    end

    it 'creates a contact with the correct name' do
      expect(response['name']).to eql('John Jacob')
    end
  end

  describe '#find_account_by_hbx_id' do
    let(:response) do
      VCR.use_cassette('find_account_by_name') do
        subject.create_account(payload: account_params)
        subject.find_account_by_hbx_id(hbx_id)
      end
    end

    it 'finds the correct account' do
      expect(response).to be_an_instance_of(String)
    end
  end

  describe '#find_contacts_by_account' do
    let(:response) do
      VCR.use_cassette('find_contacts_by_account') do
        account = subject.create_account(payload: account_params)
        subject.create_contact_for_account(payload: contact_params.merge('account.id': account['id']))
        response = subject.find_account_by_hbx_id(hbx_id)
        subject.find_contacts_by_account(response)
      end
    end

    it 'finds the correct contacts' do
      expect(response['records'].first['name']).to eql('John Jacob')
    end
  end

  describe '#update_account' do
    let(:response) do
      VCR.use_cassette('update_account') do
        account = subject.create_account(payload: account_params)
        subject.update_account(hbx_id: hbx_id, payload: account_params.merge('name': 'Tim Robinson'))
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
          payload: account_params
        )
        contact = subject.create_contact_for_account(
          payload: contact_params.merge('account.id': account['id'])
        )
        subject.update_contact(id: contact['id'], payload: contact_params.merge('first_name': 'Tim'))
      end
    end

    it "should update contact" do 
      expect(response['first_name']).to eql('Tim')
    end
  end

  describe '#update_contact_by_hbx_id' do
    let(:response) do
      VCR.use_cassette('update_contact_by_hbx_id') do
        account = subject.create_account(payload: account_params)
         
        subject.create_contact_for_account(payload: contact_params.merge('account_id': account['id']))
        subject.update_contact_by_hbx_id(hbx_id: hbx_id, payload: contact_params.merge('first_name': 'Tim'))
      end
    end

    it "should update contact" do 
      expect(response['first_name']).to eql('Tim')
    end
  end

  describe '#find_contact_by_hbx_id' do 

    let(:response) do
      VCR.use_cassette('find_contact_by_hbx_id') do
        account = subject.create_account(payload: account_params)
         
        subject.create_contact_for_account(payload: contact_params.merge('account.id': account['id']))
          
        subject.find_contact_by_hbx_id(hbx_id)
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
