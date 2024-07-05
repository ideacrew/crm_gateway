# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')

RSpec.describe Transmittable::Transmission, type: :model do
  include_context 'a full transmittable setup'

  describe 'fields' do
    it { is_expected.to have_field(:key).of_type(Symbol) }
    it { is_expected.to have_field(:title).of_type(String) }
    it { is_expected.to have_field(:description).of_type(String) }
    it { is_expected.to have_field(:started_at).of_type(DateTime) }
    it { is_expected.to have_field(:ended_at).of_type(DateTime) }
    it { is_expected.to have_field(:transmission_id).of_type(String) }
  end

  describe 'associations' do
    before do
      transaction
    end

    describe 'belongs_to :job' do
      it 'returns the job object' do
        expect(transmission.job).to eq(job)
      end
    end
  end
end
