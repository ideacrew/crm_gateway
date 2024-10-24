# frozen_string_literal: true

require 'rails_helper'
require 'aca_entities/crm/libraries/crm_library'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')

RSpec.describe Operations::SugarCRM::CompareRequest do
  include Dry::Monads[:do, :result]

  describe '#call' do
    include_context 'sugar account and contacts'
    include_context 'two full transmittable objects with one family each for the same family hbx id'

    let(:crm_account_contact_payload) do
      crm_account_params = AcaEntities::Crm::Transformers::SugarAccountTo::Account.new.call(
        sugar_acount_and_contact_params
      ).success

      AcaEntities::Crm::Operations::CreateAccount.new.call(crm_account_params).success.to_json
    end

    context 'with invalid params' do
      context 'with missing keys' do
        it 'returns a failure result' do
          expect(subject.call).to eq(Failure('a valid after_updated_at is required'))
        end
      end

      context 'with missing after_updated_at' do
        let(:input_params) { { family: double('Family') } }

        it 'returns a failure result' do
          expect(subject.call(input_params)).to eq(Failure('a valid after_updated_at is required'))
        end
      end

      context 'with incorrect after updated at format' do
        let(:input_params) { { after_updated_at: DateTime.new, family: double('Family') } }

        it 'returns a failure result' do
          expect(subject.call(input_params)).to eq(Failure('a valid after_updated_at is required'))
        end
      end

      context 'with missing family' do
        let(:input_params) { { after_updated_at: Time.now.utc } }

        it 'returns a failure result' do
          expect(subject.call(input_params)).to eq(Failure('a valid family is required'))
        end
      end

      context 'with invalid after_updated_at' do
        let(:input_params) { { after_updated_at: 'invalid', family: double('Family') } }

        it 'returns a failure result' do
          expect(subject.call(input_params)).to eq(Failure('a valid after_updated_at is required'))
        end
      end

      context 'with invalid family' do
        let(:input_params) { { after_updated_at: Time.now.utc, family: 'invalid' } }

        it 'returns a failure result' do
          expect(subject.call(input_params)).to eq(Failure('a valid family is required'))
        end
      end
    end

    context 'with an eligible previous subject' do
      let(:after_updated_at) { Time.now.utc }
      let(:input_params) { { after_updated_at: after_updated_at, family: family2, force_sync: false } }

      context 'with a stale action' do
        let(:after_updated_at) { Time.now.utc - 10.days }

        it 'returns a success result' do
          family2.update(outbound_payload: crm_account_contact_payload)
          result = subject.call(input_params)
          expect(result.success).to be_a(Entities::AccountComparison)
          expect(result.success.action).to eq(:stale)
          expect(result.success.account_action).to eq(:stale)
          expect(result.success.contacts.map(&:action).uniq).to eq([:stale])
        end
      end

      context 'with a noop action' do
        before do
          family1.update(outbound_payload: crm_account_contact_payload)
          family2.update(outbound_payload: crm_account_contact_payload)
        end

        it 'returns a success result' do
          result = subject.call(input_params)
          expect(result.success).to be_a(Entities::AccountComparison)
          expect(result.success.action).to eq(:noop)
        end
      end

      context 'with a update action' do
        let(:sugar_acount_and_contact_params_2) do
          params_2 = sugar_acount_and_contact_params.deep_dup
          params_2.merge!(name: 'Updated Name')
          params_2[:contacts].each_with_index do |contact, ind|
            contact.merge!(first_name: "Updated Name #{ind.next}")
          end

          params_2
        end

        let(:crm_account_contact_payload2) do
          crm_account_params = AcaEntities::Crm::Transformers::SugarAccountTo::Account.new.call(
            sugar_acount_and_contact_params_2
          ).success

          AcaEntities::Crm::Operations::CreateAccount.new.call(crm_account_params).success.to_json
        end

        before :each do
          family1.update(outbound_payload: crm_account_contact_payload)
          family2.update(outbound_payload: crm_account_contact_payload2)
        end

        it 'returns a success result' do
          result = subject.call(input_params)
          expect(result.success).to be_a(Entities::AccountComparison)
          expect(result.success.action).to eq(:update)
        end
      end
    end

    context 'without an eligible previous subject' do
      include_context 'a full transmittable setup with family as subject'

      before do
        allow(subject).to receive(:fetch_sugar_account).with(
          nil, family, false
        ).and_return(Success(nil))
        family.update(outbound_payload: crm_account_contact_payload)
      end

      let(:input_params) { { after_updated_at: Time.now.utc + 10.days, family: family } }

      it 'returns a success result' do
        result = subject.call(input_params)
        expect(result.success).to be_a(Entities::AccountComparison)
        expect(result.success.action).to eq(:create)
      end
    end

    context "with a nil Sugar Account" do
      include_context 'a full transmittable setup with family as subject'

      let(:input_params) { { after_updated_at: Time.now.utc + 10.days, family: family } }

      before :each do
        allow_any_instance_of(SugarCRM::Services::Connection).to receive(:fetch_account_including_contacts_by_hbx_id).with(family.primary_person_hbx_id).and_return(nil)
        allow(subject).to receive(:fetch_previous_crm_account).with(nil, false).and_return(Success(nil))
        family.update(outbound_payload: crm_account_contact_payload)
      end

      it "returns a success result" do
        result = subject.call(input_params)
        expect(result.success).to be_a(Entities::AccountComparison)
        expect(result.success.action).to eq(:create)
      end
    end
  end
end
