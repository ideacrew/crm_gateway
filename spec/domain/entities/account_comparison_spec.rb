# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entities::AccountComparison do
  let(:comparison_action) { :create }

  let(:valid_input) do
    {
      action: comparison_action,
      account_hbx_id: '12345',
      account_action: :update,
      response_code: '200',
      response_message: 'Account updated successfully',
      response_body: { account_id: '12345' }.to_json,
      contacts: [
        {
          hbx_id: 'contact1',
          action: :create,
          response_code: '200',
          response_message: 'Contact created successfully',
          response_body: { contact_id: 'contact1' }.to_json
        }
      ]
    }
  end

  context 'with valid input' do
    it 'creates an AccountComparison entity' do
      expect { Entities::AccountComparison.new(valid_input) }.not_to raise_error
    end

    context '#noop_or_stale?' do
      let(:account_comparison) { Entities::AccountComparison.new(valid_input) }

      context 'when action is :noop' do
        let(:comparison_action) { :noop }

        it 'returns true' do
          expect(account_comparison.noop_or_stale?).to be_truthy
        end
      end

      context 'when action is :stale' do
        let(:comparison_action) { :stale }

        it 'returns true' do
          expect(account_comparison.noop_or_stale?).to be_truthy
        end
      end

      context 'when action is not :noop or :stale' do
        let(:comparison_action) { :update }

        it 'returns false' do
          expect(account_comparison.noop_or_stale?).to be_falsey
        end
      end
    end
  end

  context 'with missing mandatory fields' do
    let(:missing_mandatory_fields) do
      {
        account_hbx_id: '12345',
        account_action: :update,
        contacts: [
          {
            hbx_id: 'contact1',
            action: :add,
            response_code: '400',
            response_message: 'Unable to create contact successfully'
          }
        ]
      }
    end

    it 'raises an error' do
      expect do
        Entities::AccountComparison.new(missing_mandatory_fields)
      end.to raise_error(Dry::Struct::Error)
    end
  end

  context 'with invalid contacts structure' do
    let(:invalid_contacts) do
      {
        action: :create,
        account_hbx_id: '12345',
        account_action: :update,
        contacts: [{ hbx_id: 'contact1' }]
      }
    end

    it 'raises an error for invalid contacts' do
      expect { Entities::AccountComparison.new(invalid_contacts) }.to raise_error(Dry::Struct::Error)
    end
  end

  context 'with all optional fields omitted' do
    let(:optional_fields_omitted) do
      {
        action: :create
      }
    end

    it 'creates an AccountComparison entity without optional fields' do
      expect { Entities::AccountComparison.new(optional_fields_omitted) }.not_to raise_error
    end
  end
end
