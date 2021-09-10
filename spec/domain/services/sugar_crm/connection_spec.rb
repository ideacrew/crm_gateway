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
          first_name: 'John',
          last_name: 'Jacob'
        )

        subject.create_contact_for_account(
          account_id: account['id'],
          first_name: 'John',
          last_name: 'Jacob'
        )
      end
    end

    it 'creates a contact with the correct name' do
      expect(response['name']).to eql('John Jacob')
    end
  end

  describe 'find_account_by_name' do
    let(:response) do
      VCR.use_cassette('find_account_by_name') do
        subject.find_account_by_name('John Jacob')
      end
    end

    it 'finds the correct account' do
      expect(response['records'].first['name']).to eql('John Jacob')
    end
  end

  describe 'find_contacts_by_account' do
    let(:response) do
      VCR.use_cassette('find_contacts_by_account') do
        response = subject.find_account_by_name('John Jacob')

        subject.find_contacts_by_account(
          response['records'].first['id']
        )
      end
    end

    it 'finds the correct contacts' do
      expect(response['records'].first['name']).to eql('John Jacob')
    end
  end
end
