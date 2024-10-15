# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::Families::CreatedOrUpdatedProcessor, dbclean: :after_each do
  include Dry::Monads[:result]

  include_context 'sugar account and contacts'

  let(:after_save_updated_at) do
    AcaEntities::Operations::DateTimeTransforms::ConvertTimeToString.new.call(
      { time: Time.zone.now }
    ).success
  end

  let(:compare_contacts_params1) do
    cv3_family[:family_members].map do |member|
      { action: :create, hbx_id: member[:hbx_id] }
    end
  end

  let(:comparison_params1) do
    {
      action: :create,
      account_hbx_id: family_hbx_id,
      account_action: :update,
      contacts: compare_contacts_params1
    }
  end

  let(:compare_contacts_params2) do
    cv3_family[:family_members].map do |member|
      {
        action: :update,
        hbx_id: member[:hbx_id],
        response_code: '200',
        response_body: { contact_id: member[:hbx_id] }.to_json,
        response_message: 'Contact updated successfully'
      }
    end
  end

  let(:comparison_params2) do
    {
      action: :create,
      account_hbx_id: family_hbx_id,
      account_action: :update,
      response_code: '200',
      response_body: { account_id: family_hbx_id }.to_json,
      response_message: 'Account updated successfully',
      contacts: compare_contacts_params2
    }
  end

  let(:compare_object1) do
    Operations::AccountComparison::Create.new.call(comparison_params1).success
  end

  let(:compare_object2) do
    Operations::AccountComparison::Create.new.call(comparison_params2).success
  end

  before :each do
    allow(subject).to receive(:compare_accounts).and_return(Success(compare_object1))
    allow(subject).to receive(:update_sugar_crm).and_return(Success(compare_object2))
  end

  describe "Success" do

    before do
      @result = subject.call(
        {
          inbound_family_cv: cv3_family,
          after_updated_at: after_save_updated_at
        }
      )
    end

    context "with valid params" do
      it "returns a success response" do
        expect(@result).to be_success
        expect(@result.success).to be_a(Entities::AccountComparison)
      end
    end

    context 'creates transmittable jobs' do
      let(:request_account_transactions) { Transmittable::Transaction.where(key: :account_created_or_updated_request) }
      let(:request_contact_transactions) { Transmittable::Transaction.where(key: :contact_created_or_updated_request) }
      let(:transmittable_subject) { Family.all.first }
      let(:transmittable_job) { Transmittable::Job.where(key: :family_created_or_updated).first }

      # 2 transactions for each family member as contacts + 2 transactions for the family as an account
      # One request transaction and response transaction per contact and account
      let(:transactions_count) { (cv3_family[:family_members].count * 2) + 2 }

      it 'creates a Job' do
        expect(Transmittable::Job.count).to eq 1
      end

      it 'creates both request and response transmissions' do
        expect(transmittable_job.transmissions.count).to eq 2
        expect(transmittable_job.transmissions.pluck(:key)).to eq(%i[family_created_or_updated_request family_created_or_updated_response])
        expect(Transmittable::Transmission.where(key: :family_created_or_updated_request).count).to eq 1
        expect(Transmittable::Transmission.where(key: :family_created_or_updated_response).count).to eq 1
      end

      it 'creates a subject that is a family' do
        expect(Family.all.count).to eq 1
        expect(transmittable_subject.job_id).to eq(transmittable_job.id.to_s)
        expect(transmittable_subject.transactions.count).to eq(transactions_count)
      end

      it 'creates account transaction' do
        expect(request_account_transactions.count).to eq 1
        expect(request_account_transactions.first.transactable).to eq(transmittable_subject)
      end

      it 'creates multiple Contact Transactions' do
        family_members = cv3_family[:family_members]
        expect(request_contact_transactions.count).to eq family_members.count
        expect(request_contact_transactions.map(&:transactable).uniq).to eq([transmittable_subject])
      end

      it 'has a subject with transactions' do
        expect(transmittable_subject.transactions).to be_truthy
      end

      it 'creates a relationship between transactions and transmissions' do
        Transmittable::Transaction.all.each do |transaction|
          expect(transaction.transmissions.first).to be_a(Transmittable::Transmission)
        end
      end

      it 'persists an outbound payload' do
        expect(transmittable_subject.outbound_payload).to be_truthy
      end
    end
  end

  describe "Failure" do

    context 'without valid inbound_family_cv' do
      before do
        @result = subject.call(
          {
            inbound_family_cv: {},
            after_updated_at: after_save_updated_at
          }
        )
      end

      it "returns a failure response" do
        expect(@result.failure?).to be_truthy
      end

      it "returns a failure message" do
        expect(@result.failure).to eql('Inbound family cv payload not present.')
      end
    end

    context 'without valid after_updated_at' do
      let(:input_params) { { inbound_family_cv: cv3_family, after_updated_at: :testing } }

      it 'returns a failure monad with a message' do
        result = subject.call(input_params)
        expect(result.failure?).to be_truthy
        expect(result.failure).to eq(
          'Invalid After Updated At timestamp. Must be a valid timestamp in string format.'
        )
      end
    end
  end
end
