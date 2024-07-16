# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::SugarCRM::FetchAccount do
  include Dry::Monads[:do, :result]

  include_context 'sugar account and contacts'

  let(:result) { subject.call({ account_hbx_id: account_hbx_id }) }

  let(:account_response_monad) { Success(input_params) }

  describe '#call' do
    before :each do
      allow(subject).to receive(:sugar_account).with(account_hbx_id).and_return(account_response_monad)
    end

    context 'for success' do
      include_context 'sugar account and contacts'

      it 'returns the account with the contacts' do
        expect(result).to be_success
        expect(result.success).to be_a(AcaEntities::Crm::Account)
      end
    end

    context 'for failure' do
      context 'when account_hbx_id is not a string' do
        let(:account_hbx_id) { 123 }

        it 'returns a failure monad' do
          expect(result).to be_failure
          expect(result.failure).to eq("Account HBX ID is required and must be a string. Received: #{account_hbx_id}")
        end
      end

      context 'when account_hbx_id is not present' do
        let(:account_hbx_id) { nil }

        it 'returns a failure monad' do
          expect(result).to be_failure
          expect(result.failure).to eq("Account HBX ID is required and must be a string. Received: #{account_hbx_id}")
        end
      end

      context 'when the integration with Sugar raises an error' do
        let(:account_response_monad) { Failure(error_message) }
        let(:error_message) { "Unable to fetch account from SugarCRM: Blah! Blah! for account: #{account_hbx_id}" }

        it 'returns a failure monad' do
          expect(result).to be_failure
          expect(result.failure).to eq(error_message)
        end
      end

      context 'when the parsed account params cannot be transformed' do
        let(:account_params) { 'Blah! Blah!' }
        let(:account_response_monad) { Success(account_params) }
        let(:error_message) { "Unable to transform Sugar Account: no implicit conversion of Symbol into Integer" }

        it 'returns a failure monad' do
          expect(result).to be_failure
          expect(result.failure).to eq(error_message)
        end
      end
    end
  end
end
