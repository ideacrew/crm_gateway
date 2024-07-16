# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::Transmittable::GenerateResponseObjects, dbclean: :after_each do
  let(:family) {FactoryBot.create(:family)}
  subject { described_class.new }
  let(:key) { :sugar_update_request}
  let(:payload) { { message: "A REQUEST PAYLOAD" } }

  let(:required_params) do
    {
      key: key,
      payload: payload,
      correlation_id: family.family_hbx_id,
      subject_gid: family.to_global_id.uri
    }
  end

  context 'sending invalid params' do
    it 'should return a failure with missing key' do
      result = subject.call(required_params.except(:key))
      expect(result.failure).to eq('Cannot save a failure response without a key')
    end

    it 'should return a failure with missing payload' do
      result = subject.call(required_params.except(:payload))
      expect(result.failure).to eq('Cannot save a failure response without a payload')
    end

    it 'should return a failure with missing correlation_id' do
      result = subject.call(required_params.except(:correlation_id))
      expect(result.failure).to eq('Cannot link a subject without a correlation_id')
    end

    it 'should return a failure with missing subject_gid' do
      result = subject.call(required_params.except(:subject_gid))
      expect(result.failure).to eq('Cannot link a subject without a subject_gid')
    end
  end

  context 'sending valid params' do
    before do
      @result = subject.call(required_params)
    end

    it "Should not have any errors" do
      expect(@result.success?).to be_truthy
    end

    it 'should generate a job' do
      expect(@result.value![:job].class).to eq Transmittable::Job
    end

    it 'should generate a transaction' do
      expect(@result.value![:transaction].class).to eq Transmittable::Transaction
    end

    it 'should have a transaction payload' do
      expect(@result.value![:transaction].json_payload).not_to be_nil
    end

    it 'should generate a transmission' do
      expect(@result.value![:transmission].class).to eq Transmittable::Transmission
    end

    it 'should have a subject' do
      expect(@result.value![:subject].class).to eq Family
    end
  end
end
