class EventsController < ApplicationController
  def index
    @events = Event.all.to_a
  end

  def retry
    @event = Event.find(params[:id])
    if @event.event_name_identifier == 'Family Update'
      SugarCRM::Operations::Families:HandleFamilyUpdate.new.call(@event.data, @event)

    elsif @event.event_name_identifier == 'Primary Subscriber Update'
      SugarCRM::Operations::Families:HandlePrimaryPersonUpdate.new.call(@event.data, @event)
    end
  end
end