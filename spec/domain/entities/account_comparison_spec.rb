# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entities::AccountComparison do
  context 'with valid input' do
    let(:valid_input) do
      {
        action: :create,
        account_hbx_id: '12345',
        account_action: :update,
        contacts: [{ hbx_id: 'contact1', action: :create }]
      }
    end

    it 'creates an AccountComparison entity' do
      expect { Entities::AccountComparison.new(valid_input) }.not_to raise_error
    end
  end

  context 'with missing mandatory fields' do
    let(:missing_mandatory_fields) do
      {
        account_hbx_id: '12345',
        account_action: :update,
        contacts: [{ hbx_id: 'contact1', action: :add }]
      }
    end

    it 'raises an error' do
      expect { Entities::AccountComparison.new(missing_mandatory_fields) }.to raise_error(Dry::Struct::Error)
    end
  end

  context 'with invalid contacts structure' do
    let(:invalid_contacts) do
      {
        action: :create,
        account_hbx_id: '12345',
        account_action: :update,
        contacts: [{ hbx_id: 'contact1' }] # Missing :action
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
