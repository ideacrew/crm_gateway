# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::Families::UpdatedOrCreatedProcessor, dbclean: :after_each do
  let(:file_data) { File.read("spec/test_data/cv3_payload.json") }
  let(:cv3_family_payload) { JSON.parse(JSON.parse(file_data), symbolize_names: true) }
  let(:after_save_updated_at) { DateTime.now.to_s }

  describe "Success" do

    before do
      @result = described_class.new.call({
                                           inbound_family_cv: cv3_family_payload,
                                           after_updated_at: after_save_updated_at
                                         })
    end

    context "with valid params" do

      it "returns a success response" do
        expect(@result).to be_success
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