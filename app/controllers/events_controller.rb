class EventsController < ApplicationController
  def index
    @events = Event.all.to_a
  end

  def update
    @events = Event.find_by(id: params[:id])
  end

  def create
    @events = Event.new(
      event_name_identifier: event_name_identifier,
      aasm_state: 'draft'
    )
    @events.save
  end
end
