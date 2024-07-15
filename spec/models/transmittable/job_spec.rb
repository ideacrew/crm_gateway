# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')

RSpec.describe Transmittable::Job, type: :model do
  include_context 'a full transmittable setup with family as subject'

  describe '#before_create' do
    let(:job) { FactoryBot.create(:transmittable_job) }

    it 'populates message_id for the job' do
      expect(job.message_id).to be_present
    end
  end

  describe 'associations' do
    describe 'has_many :transmissions' do
      it 'returns the transmissions associated with the job' do
        expect(job.transmissions).to include(transmission)
      end
    end
  end
end
