# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SugarCRM::Operations::Payload::Dob do
  subject do
    described_class.new
  end

    context "Valid dob" do
      dob = "1769-08-15"
      let(:result) {subject.call(dob)}

      it "returns a success response" do
        expect(result).to be_success
      end
    end

    context "Invalid dob" do
      dob = "174455-53-42"
      let(:result) {subject.call(dob)}

      it "returns a failure response" do
        expect(result).to_not be_success
      end
    end
end