# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')

RSpec.describe Transmittable::Transaction, type: :model do
  include_context 'a full transmittable setup with family as subject'

  describe 'fields' do
    it { is_expected.to have_field(:key).of_type(Symbol) }
    it { is_expected.to have_field(:title).of_type(String) }
    it { is_expected.to have_field(:description).of_type(String) }
    it { is_expected.to have_field(:started_at).of_type(DateTime) }
    it { is_expected.to have_field(:ended_at).of_type(DateTime) }
    it { is_expected.to have_field(:transaction_id).of_type(String) }
    it { is_expected.to have_field(:json_payload).of_type(Hash) }
    it { is_expected.to have_field(:xml_payload).of_type(String) }
  end

  describe 'associations' do
    describe 'belongs_to :transactable' do
      it 'returns the transactable object' do
        expect(transaction.transactable).to eq(family)
      end
    end

    describe 'has_many :transactions_transmissions' do
      it 'returns the transactions_transmissions associated with the transaction' do
        expect(transaction.transactions_transmissions.first).to be_a(Transmittable::TransactionsTransmissions)
      end
    end
  end
end
