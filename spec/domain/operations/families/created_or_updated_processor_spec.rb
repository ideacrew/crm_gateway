# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::Families::CreatedOrUpdatedProcessor, dbclean: :after_each do
  include Dry::Monads[:result]

  include_context 'sugar account and contacts'

  let(:after_save_updated_at) { DateTime.now.to_s }

  let(:compare_contacts_params) do
    cv3_family[:family_members].map do |member|
      { action: :create, hbx_id: member[:hbx_id] }
    end
  end

  let(:comparison_params) do
    {
      action: :create,
      account_hbx_id: family_hbx_id,
      account_action: :update,
      contacts: compare_contacts_params
    }
  end

  let(:compare_object) do
    Operations::AccountComparison::Create.new.call(comparison_params).success
  end

  before :each do
    allow(subject).to receive(:compare_accounts).and_return(Success(compare_object))
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

    context "persisted objects" do

      it "persists a Job" do
        expect(Transmittable::Job.count).to eq 1
      end
      it "persists a Transmission" do
        expect(Transmittable::Transmission.count).to eq 1
      end

      it "persists a Family object" do
        expect(Family.count).to eq 1
      end

      it "persists an Account Transaction" do
        expect(Transmittable::Transaction.where(key: :account_created_or_updated).count).to eq 1
      end

      it "persists multiple Contact Transactions" do
        family_members = cv3_family[:family_members]
        expect(Transmittable::Transaction.where(key: :contact_created_or_updated).count).to eq family_members.count
      end

      it "has a subject with transactions" do
        expect(Family.first.transactions).to be_truthy
      end

      it "has a relationship between transactions and transmissions" do
        Transmittable::Transaction.all.each do |transaction|
          expect(transaction.transmissions).to be_truthy
        end
      end

      it "persists an outbound payload" do
        expect(Family.first.outbound_payload).to be_truthy
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
        expect(@result.failure).to eql("Inbound family cv payload not present")
      end
    end

    context 'without valid after_updated_at' do
      let(:input_params) { { inbound_family_cv: cv3_family, after_updated_at: :testing } }

      it 'returns a failure monad with a message' do
        result = subject.call(input_params)
        expect(result.failure?).to be_truthy
        expect(result.failure).to match(/Invalid After Updated At timestamp. Error raised/)
      end
    end
  end
end
