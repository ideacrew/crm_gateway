# frozen_string_literal: true

require 'rails_helper'
require 'aca_entities/crm/libraries/crm_library'
require Rails.root.join('spec/shared_contexts/sugar_crm_account_data.rb')
require Rails.root.join('spec/shared_contexts/transmittable_data.rb')

RSpec.describe Operations::SugarCRM::Update do
  include Dry::Monads[:do, :result]

  let(:action) { :create }
  let(:account_action) { :update }
  let(:contact_action) { :create }
  let(:comparison_params) do
    {
      action: action,
      account_hbx_id: family.family_hbx_id,
      account_action: account_action,
      response_code: '200',
      response_message: 'Account updated successfully',
      response_body: { account_id: '12345' }.to_json,
      contacts: [
        {
          hbx_id: family.primary_person_hbx_id,
          action: contact_action,
          response_code: '200',
          response_message: 'Contact created successfully',
          response_body: { contact_id: 'contact1' }.to_json
        }
      ]
    }
  end
  let(:comparison) do
    Operations::AccountComparison::Create.new.call(comparison_params).success
  end
  let(:request_objects) { { job: job, transmission: transmission, subject: family, transaction: transaction } }
  let(:input) { { comparison: comparison, request_objects: request_objects } }

  describe '#call' do
    include_context 'sugar account and contacts'
    include_context 'a full transmittable setup with family as subject'

    let(:crm_account_contact_payload) do
      crm_account_params = AcaEntities::Crm::Transformers::SugarAccountTo::Account.new.call(
        sugar_acount_and_contact_params
      ).success

      AcaEntities::Crm::Operations::CreateAccount.new.call(crm_account_params).success.to_json
    end

    context 'without params' do
      let(:input) { {} }

      it 'returns a Failure' do
        expect(subject.call(input).failure).to eq('Invalid comparison or request objects.')
      end
    end

    context 'with invalid comparison' do
      let(:input) { { comparison: 'comparison', request_objects: request_objects } }

      it 'returns a Failure' do
        expect(subject.call(input).failure).to eq('Invalid comparison or request objects.')
      end
    end

    context 'with invalid request_objects' do
      let(:input) { { comparison: comparison, request_objects: {} } }

      it 'returns a Failure' do
        expect(subject.call(input).failure).to eq('Invalid comparison or request objects.')
      end
    end

    context 'with invalid request_objects' do
      let(:input) { { comparison: comparison, request_objects: {} } }

      it 'returns a Failure' do
        expect(subject.call(input).failure).to eq('Invalid comparison or request objects.')
      end
    end

    context 'with valid comparison and request_objects' do
      before do
        allow(subject).to receive(:update_sugar_for_account).with(any_args).and_return(
          Success(
            {
              response_code: 200,
              response_body: { account_id: family.family_hbx_id }.to_json,
              response_message: "Account with hbx_id: #{family.family_hbx_id} created successfully in SugarCRM"
            }
          )
        )

        allow(subject).to receive(:update_sugar_for_contacts).with(any_args).and_return(
          Success(
            {
              family.primary_person_hbx_id => {
                response_code: 200,
                response_body: { contact_id: 'contact1' }.to_json,
                response_message: "Contact with hbx_id: #{family.primary_person_hbx_id} created successfully in SugarCRM"
              }
            }
          )
        )

        family.update(outbound_payload: crm_account_contact_payload)
      end

      it 'returns a Success' do
        result = subject.call(input)
        expect(result.success).to be_a(Entities::AccountComparison)
        expect(result.success.response_code).to eq('200')
        expect(result.success.contacts.first.response_code).to eq('200')
      end
    end
  end
end
