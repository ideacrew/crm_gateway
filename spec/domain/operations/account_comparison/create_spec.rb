# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::AccountComparison::Create do
  subject(:operation) { described_class.new }

  let(:valid_params) do
    {
      action: :create_and_update,
      account_hbx_id: '12345',
      account_action: :update,
      contacts: [{ hbx_id: 'contact1', action: :create }]
    }
  end

  let(:invalid_params) do
    {
      action: :test,
      account_hbx_id: '12345',
      account_action: :test,
      contacts: [{ hbx_id: 'contact1', action: :test }]
    }
  end

  describe '#call' do
    context 'when valid parameters are provided' do
      it 'returns a success result with an AccountComparison entity' do
        result = operation.call(valid_params)

        expect(result).to be_success
        expect(result.value!).to be_an_instance_of(Entities::AccountComparison)
        expect(result.value!.to_h).to include(valid_params)
      end
    end

    context 'when invalid parameters are provided' do
      it 'returns a failure result with error messages' do
        result = operation.call(invalid_params)

        expect(result).to be_failure
        expect(result.failure).to include(:account_action, :contacts)
      end
    end
  end
end
