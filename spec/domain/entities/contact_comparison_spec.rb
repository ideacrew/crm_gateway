# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entities::ContactComparison do
  describe 'initialization' do
    let(:params) { { hbx_id: '12345', action: :create } }
    let(:subject) { described_class.new(params) }

    it 'creates a ContactComparison instance with hbx_id and action' do
      expect(subject.hbx_id).to eq('12345')
      expect(subject.action).to eq(:create)
    end
  end

  describe 'attribute validation' do
    context 'when hbx_id is missing' do
      it 'raises an error' do
        expect { described_class.new(action: :create) }.to raise_error(Dry::Struct::Error)
      end
    end

    context 'when action is missing' do
      it 'raises an error' do
        expect { described_class.new(hbx_id: '12345') }.to raise_error(Dry::Struct::Error)
      end
    end

    context 'when action is not a recognized symbol' do
      it 'raises an error' do
        expect do
          described_class.new(hbx_id: '12345', action: :unknown_action)
        end.to raise_error(
          Dry::Struct::Error, /:action violates constraints/
        )
      end
    end
  end
end
