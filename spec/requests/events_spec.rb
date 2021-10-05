# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Events", type: :request do
  include Dry::Monads[:result, :do, :try]
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe 'GET /:id/retry' do
    let(:event) do
      Event.create(
        event_name_identifier: 'Family Update',
        aasm_state: "successful",
        data: {name: 'Tom', dob: '20-14-07', family_members: []}
      )
    end

    context "retry of a family update" do
      let(:event_name_identifier) {"Family Update"}
      let(:event_handler) {instance_double("SugarCRM::Operations::Families::HandleFamilyUpdate")}

      before do
        allow(SugarCRM::Operations::Families::HandleFamilyUpdate).to receive(:new).and_return(event_handler)
        allow(event_handler).to receive(:call).and_return(Success("String"))
      end

      it "retries the event" do
        get retry_event_path(event)
        expect(event_handler).to have_received(:call)
      end

    end

    context "retry of a primary" do
      let(:event_name_identifier) {"Primary Update"}
    end
  end
end
