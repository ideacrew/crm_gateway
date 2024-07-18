# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::SugarCRM::Transmittable::GenerateRequestObjects, dbclean: :after_each do

  include_context 'sugar account and contacts'

  let(:after_save_updated_at) { DateTime.now.to_s }

  describe "Success" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: cv3_family,
                                           inbound_after_updated_at: after_save_updated_at
                                         })
    end

    it "returns a success response" do
      expect(@result).to be_success
    end

    it "generates a job" do
      expect(@result.success[:job]).to be_a(Transmittable::Job)
    end

    it "generates a transmission" do
      expect(@result.success[:transmission]).to be_a(Transmittable::Transmission)
    end


    it "generates a family" do
      expect(@result.success[:subject]).to be_a(Family)
    end

    it "generates an account transaction" do
      expect(@result.success[:transaction]).to be_a(Transmittable::Transaction)
    end
  end

  describe "Failure" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: {},
                                           inbound_after_updated_at: after_save_updated_at
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