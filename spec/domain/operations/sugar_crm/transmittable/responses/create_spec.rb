# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')

RSpec.describe Operations::SugarCRM::Transmittable::Responses::Create do
  include_context 'sugar account and contacts'

  let(:request_objects) do
    Operations::SugarCRM::Transmittable::GenerateRequestObjects.new.call(
      { inbound_family_cv: cv3_family, inbound_after_updated_at: after_save_updated_at }
    ).success
  end

  let(:contacts_params) do
    cv3_family[:family_members].collect do |f_member|
      {
        hbx_id: f_member[:hbx_id],
        action: :create,
        response_code: '200',
        response_message: 'Contact created successfully',
        response_body: { contact_id: f_member[:hbx_id] }.to_json
      }
    end
  end

  let(:comparison_params) do
    {
      action: :create,
      account_hbx_id: family_hbx_id,
      account_action: :create,
      response_code: '200',
      response_message: 'Account created successfully',
      response_body: { account_id: family_hbx_id }.to_json,
      contacts: contacts_params
    }
  end

  let(:after_save_updated_at) { DateTime.now.to_s }

  let(:comparison) do
    Operations::AccountComparison::Create.new.call(comparison_params).success
  end

  describe '#call' do
    context 'with valid comparison and request objects' do
      let(:result) { subject.call({ comparison: comparison, request_objects: request_objects }).success }

      it 'returns transmittable objects' do
        expect(result.keys.sort).to eq(
          [:job, :request_transactions, :request_transmission, :response_transactions, :response_transmission, :subject]
        )
      end

      it 'returns job' do
        expect(result[:job]).to be_a(Transmittable::Job)
      end

      it 'returns a request transmission' do
        expect(result[:request_transmission]).to be_a(Transmittable::Transmission)
      end

      it 'returns a response transmission' do
        expect(result[:response_transmission]).to be_a(Transmittable::Transmission)
      end

      it 'returns a subject' do
        expect(result[:subject]).to be_a(Family)
      end

      it 'returns request transactions' do
        expect(result[:request_transactions].map(&:class).uniq).to eq([Transmittable::Transaction])
      end

      it 'returns response transactions' do
        expect(result[:response_transactions].map(&:class).uniq).to eq([Transmittable::Transaction])
      end

      it "generates a process status for job" do
        expect(result[:job].process_status).to be_a(Transmittable::ProcessStatus)
      end
  
      it "generates a process state for job" do
        expect(result[:job].process_status.process_states.first).to be_a(Transmittable::ProcessState)
      end
  
      it "generates a process status for transmission" do
        expect(result[:response_transmission].process_status).to be_a(Transmittable::ProcessStatus)
      end
  
      it "generates a process state for transmission" do
        expect(result[:response_transmission].process_status.process_states.first).to be_a(Transmittable::ProcessState)
      end
  
      it "generates a process status for transaction" do
        expect(result[:request_transactions].map(&:process_status).first).to be_a(Transmittable::ProcessStatus)
      end
  
      it "generates a process state for transaction" do
        expect(result[:request_transactions].map(&:process_status).first.process_states.first).to be_a(Transmittable::ProcessState)
      end
    end

    context 'with invalid input params' do
      it 'returns a failure message' do
        expect(
          subject.call({ comparison: nil, request_objects: nil }).failure
        ).to eq('Invalid comparison or request objects.')
      end
    end
  end
end
