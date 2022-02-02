# frozen_string_literal: true

require 'rails_helper'
require 'date'
# require 'aasm/rspec'

RSpec.describe Event, type: :model, dbclean: :around_each do
  describe "AASM states" do
    it "should initialize with an aasm_state of received" do
      expect(Event.new.aasm_state).to eq("received")
    end

    it "should go from received to processing" do
      event = Event.create
      event.process!
      event.reload
      expect(event.aasm_state).to eq("processing")
    end

    it "should not have a processed_at timestamp" do
      event = Event.create
      expect(event.processing_at.present?).to eq(false)
    end

    it "should have a processing_at timestamp" do
      event = Event.create
      event.process!
      expect(event.processing_at.present?).to eq(true)
    end
  end

  describe "GET index" do
    new_event = Event.new(updated_at: Time.now)
    old_event = Event.new(updated_at: Time.now - 3.hours)

    it "should include new_event" do
      get :index
      expect(response).to include(new_event)
    end

    it "should not include old_event" do
      get :index
      expect(response).to_not include(old_event)
    end


  end
end
