# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::Families::UpdatedOrCreatedProcessor, dbclean: :after_each do

  include_context 'sugar account and contacts'

  let(:after_save_updated_at) { DateTime.now.to_s }

  describe "Success" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: cv3_family,
                                           after_updated_at: after_save_updated_at
                                         })
    end

    context "with valid params" do

      it "returns a success response" do
        expect(@result).to be_success
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
    end
  end

  describe "Failure" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: {},
                                           after_updated_at: after_save_updated_at
                                         })
    end

    context "with invalid params" do

      it "returns a failure response" do
        expect(@result.failure?).to be_truthy
      end

      it "returns a failure message" do
        expect(@result.failure).to eql("Inbound family cv payload not present")
      end
    end
  end
end