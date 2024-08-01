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

    it 'creates job title by including family hbx_id' do
      expect(@result.success[:job].title).to include(cv3_family[:hbx_id])
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

    it "generates a process status for job" do
      expect(@result.success[:job].process_status).to be_a(Transmittable::ProcessStatus)
    end

    it "generates a process state for job" do
      expect(@result.success[:job].process_status.process_states.first).to be_a(Transmittable::ProcessState)
    end

    it "generates a process status for transmission" do
      expect(@result.success[:transmission].process_status).to be_a(Transmittable::ProcessStatus)
    end

    it "generates a process state for transmission" do
      expect(@result.success[:transmission].process_status.process_states.first).to be_a(Transmittable::ProcessState)
    end

    it "generates a process status for transaction" do
      expect(@result.success[:transaction].process_status).to be_a(Transmittable::ProcessStatus)
    end

    it "generates a process state for transaction" do
      expect(@result.success[:transaction].process_status.process_states.first).to be_a(Transmittable::ProcessState)
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
