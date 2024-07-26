# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contracts::AccountComparisonContract do
  subject(:contract) { described_class.new }

  describe '#call' do
    context 'when valid parameters are provided' do
      let(:response_code) { '200' }

      let(:valid_input) do
        {
          action: :create,
          account_hbx_id: '12345',
          account_action: :update,
          response_code: response_code,
          response_message: 'Account updated successfully',
          response_body: { account_id: '12345' }.to_json,
          contacts: [
            {
              hbx_id: 'contact1',
              action: :create,
              response_code: response_code,
              response_message: 'Contact created successfully',
              response_body: { contact_id: 'contact1' }.to_json
            },
            {
              hbx_id: 'contact2',
              action: :update,
              response_code: '400',
              response_message: 'Unable to create contact successfully',
              response_body: { error: 'Invalid contact' }.to_json
            }
          ]
        }
      end

      context 'when coercion is not needed' do
        it 'succeeds validation' do
          result = contract.call(valid_input)

          expect(result).to be_success
        end
      end

      context 'when coercion is needed' do
        let(:response_code) { 200 }

        it 'succeeds validation' do
          result = contract.call(valid_input)

          expect(result).to be_success
          expect(result[:response_code]).to be_a(String)
          expect(result[:contacts].first[:response_code]).to be_a(String)
        end
      end
    end

    context 'when action is missing' do
      let(:input_missing_action) do
        {
          account_hbx_id: '12345',
          account_action: :update,
          contacts: [
            {
              hbx_id: 'contact1',
              action: :create,
              response_code: '200',
              response_message: 'Contact created successfully'
            }
          ]
        }
      end

      it 'fails validation' do
        result = contract.call(input_missing_action)

        expect(result).to be_failure
        expect(result.errors.to_h).to have_key(:action)
      end
    end

    context 'when contacts have invalid action' do
      let(:invalid_contacts_action) do
        {
          action: :create,
          account_hbx_id: '12345',
          account_action: :update,
          contacts: [{ hbx_id: 'contact1', action: :invalid_action }]
        }
      end

      it 'fails validation for contacts' do
        result = contract.call(invalid_contacts_action)

        expect(result).to be_failure
        expect(result.errors.to_h[:contacts][0]).to have_key(:action)
      end
    end

    context 'with optional fields omitted' do
      let(:optional_fields_omitted) do
        {
          action: :create
        }
      end

      it 'passes validation when optional fields are omitted' do
        result = contract.call(optional_fields_omitted)

        expect(result).to be_success
      end
    end
  end
end
