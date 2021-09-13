require 'rails_helper'
# require 'aasm/rspec'

RSpec.describe Event, type: :model, dbclean: :around_each do
  describe "AASM states" do
    it "should initialize with an aasm_state of draft" do
      expect(Event.new.aasm_state).to eq("draft")
    end

    it "should go from draft to processing" do
      event = Event.create
      event.process!
      event.reload
      expect(event.aasm_state).to eq("processing")
    end
  end
end
