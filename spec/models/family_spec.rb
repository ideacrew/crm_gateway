# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')
require 'aca_entities/crm/libraries/crm_library'

RSpec.describe Family, type: :model do
  include_context 'a full transmittable setup with family as subject'

  describe 'fields' do
    it { is_expected.to have_field(:correlation_id).of_type(String) }
    it { is_expected.to have_field(:family_hbx_id).of_type(String) }
    it { is_expected.to have_field(:primary_person_hbx_id).of_type(String) }
    it { is_expected.to have_field(:inbound_raw_headers).of_type(String) }
    it { is_expected.to have_field(:inbound_raw_payload).of_type(String) }
    it { is_expected.to have_field(:inbound_payload).of_type(String) }
    it { is_expected.to have_field(:outbound_payload).of_type(String) }
    it { is_expected.to have_field(:job_id).of_type(String) }
    it { is_expected.to have_field(:inbound_after_updated_at).of_type(Time) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(correlation_id: 1) }
    it { is_expected.to have_index_for(primary_person_hbx_id: 1) }
    it { is_expected.to have_index_for(family_hbx_id: 1) }
    it { is_expected.to have_index_for(job_id: 1) }
  end

  describe 'scopes' do
    let!(:family) { FactoryBot.create(:family) }

    it '.by_primary_person_hbx_id' do
      expect(Family.by_primary_person_hbx_id(family.primary_person_hbx_id)).to include(family)
    end

    it '.by_family_hbx_id' do
      expect(Family.by_family_hbx_id(family.family_hbx_id)).to include(family)
    end

    it '.by_correlation_id' do
      expect(Family.by_correlation_id(family.correlation_id)).to include(family)
    end

    it '.by_job_id' do
      expect(Family.by_job_id(family.job_id)).to include(family)
    end
  end

  describe '#inbound_family_cv_hash' do
    context 'when inbound_payload is present' do
      let(:family) { FactoryBot.create(:family, inbound_payload: { test: 'value' }.to_json) }

      it 'parses the inbound_payload into a hash' do
        expect(family.inbound_family_cv_hash).to eq({ test: 'value' })
      end
    end

    context 'when inbound_payload is blank' do
      let(:family) { FactoryBot.create(:family, inbound_payload: nil) }

      it 'returns nil' do
        expect(family.inbound_family_cv_hash).to be_nil
      end
    end
  end

  describe '#outbound_account_cv_hash' do
    context 'when outbound_payload is present' do
      let(:family) { FactoryBot.create(:family, outbound_payload: { test: 'value' }.to_json) }

      it 'parses the outbound_payload into a hash' do
        expect(family.outbound_account_cv_hash).to eq({ test: 'value' })
      end
    end

    context 'when outbound_payload is blank' do
      let(:family) { FactoryBot.create(:family, outbound_payload: nil) }

      it 'returns nil' do
        expect(family.outbound_account_cv_hash).to be_nil
      end
    end
  end

  describe '#outbound_account_entity' do
    context 'when outbound_payload is present' do
      let(:date_of_birth) { (Time.zone.today - 10.years).to_s }

      let(:outbound_payload) do
        {
          hbxid_c: '12345',
          name: 'John Doe',
          dob_c: date_of_birth,
          contacts: [
            {
              hbxid_c: '12345',
              first_name: 'John',
              last_name: 'Doe',
              birthdate: date_of_birth,
              relationship_c: 'Self'
            }
          ]
        }
      end

      let(:family) { FactoryBot.create(:family, outbound_payload: outbound_payload.to_json) }

      it 'returns a account entity' do
        expect(family.outbound_account_entity).to be_a(AcaEntities::Crm::Account)
      end
    end

    context 'when outbound_payload is blank' do
      let(:family) { FactoryBot.create(:family, outbound_payload: nil) }

      it 'returns nil' do
        expect(family.outbound_account_entity).to eq(nil)
      end
    end
  end

  let(:comparison_params) do
    {
      action: :create,
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

  describe '#comparison_hash' do
    context 'when comparison_payload is present' do
      let(:family) { FactoryBot.create(:family, comparison_payload: comparison_params.to_json) }

      it 'parses the comparison_payload into a hash' do
        expect(family.comparison_hash).to be_truthy
      end
    end

    context 'when comparison_payload is blank' do
      let(:family) { FactoryBot.create(:family, comparison_payload: nil) }

      it 'returns nil' do
        expect(family.comparison_hash).to be_nil
      end
    end
  end

  describe '#comparison_entity' do
    context 'when comparison_payload is present' do
      let(:family) { FactoryBot.create(:family, comparison_payload: comparison_params.to_json) }

      it 'parses the comparison_payload into a hash' do
        expect(family.comparison_entity).to be_a(Entities::AccountComparison)
      end
    end

    context 'when comparison_payload is blank' do
      let(:family) { FactoryBot.create(:family, comparison_payload: nil) }

      it 'returns nil' do
        expect(family.comparison_entity).to be_nil
      end
    end
  end

  describe 'associations' do
    describe 'has_many :transactions' do
      it 'returns the transactions associated with the family' do
        expect(family.transactions).to include(transaction)
      end
    end
  end
end
