# frozen_string_literal: true

require 'rails_helper'

include Dry::Monads[:result]


RSpec.describe People::HandleUpdate, dbclean: :after_each do
  describe '#call' do
    subject do
      described_class.new(event: event)
    end

    let(:event) { double(Event.new) }

    let(:first_response) { OAuth2::Response.new(Faraday::Response.new(url: 'url'), {}) }
    let(:url) { 'url' }
    let(:exception) {StandardError.new}

    let(:first_action) { double(Action.new) }
    let(:second_action) { double(Action.new) }

    before do
      allow(event).to receive(:process!)
      allow(event).to receive(:complete!)
      allow(event).to receive(:fail!)

      allow(first_action).to receive(:url=)
      allow(first_action).to receive(:incoming_payload=)
      allow(first_action).to receive(:outgoing_payload=)

      allow(second_action).to receive(:exception=).and_return({})

      allow(first_response).to receive(:parsed).and_return({})

      allow(event).to receive_message_chain(:actions, :build) do |attributes|
        if attributes[:kind] == :first_step
          first_action
        else
          second_action
        end
      end
    end

    context "success" do
      before do
        allow(subject).to receive(:publish_to_crm).and_return(Success([{first_step: Success(first_response)}, { second_step: Failure(exception) }]))
        subject.call({})
      end

      it 'processed the event' do
        expect(event).to have_received(:process!)
      end

      it "the first action has a url" do
        expect(first_action).to have_received(:url=)
      end

      it "sets the second action's exception" do
        expect(second_action).to have_received(:exception=)
      end

      it "creates a success" do
        expect(event).to have_received(:complete!)
      end
    end

    context "failure" do
      before do
        allow(subject).to receive(:publish_to_crm).and_return(Failure([{first_step: Failure(first_response)}, {second_step: Failure(exception) }]))
        subject.call({})
      end

      it 'processed the event' do
        expect(event).to have_received(:process!)
      end

      it "sets the first action's url" do
        expect(first_action).to have_received(:url=)
      end

      it "sets the second action's exception" do
        expect(second_action).to have_received(:exception=)
      end

      it "creates a failure" do
        expect(event).to have_received(:fail!)
      end
    end
  end

  # describe '#publish_to_crm' do
  #   subject do
  #     described_class.new(event: event)
  #   end

  #   let(:event) { double(Event.new) }

  #   context "of a Primary Subscriber Update" do
  #     before do
  #       allow(event).to receive(:event_name_identifier).and_return("Primary Subscriber Update")
  #     end

  #     it 'calls the SugarCRM::Operations::PrimaryUpsert operation' do
  #       subject.send(:publish_to_crm, {})
  #       expect(SugarCRM::Operations::PrimaryUpsert).to receive(:new)
  #     end
  #   end

  #   context 'of a Family Update' do
  #     before do
  #       allow(event).to receive(:event_name_identifier).and_return("Family Update")
  #     end

  #     it 'calls the SugarCRM::Operations::FamilyUpsert operation' do
  #       subject.send(:publish_to_crm, {})
  #       expect(SugarCRM::Operations::FamilyUpsert).to receive(:new)
  #     end
  #   end
  # end
end
