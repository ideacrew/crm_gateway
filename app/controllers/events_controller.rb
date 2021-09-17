class EventsController < ApplicationController
  def index
    @events = Event.order_by(updated_at: :desc)
  end

  def retry
    @event = Event.find(params[:id])
    @event.retry!
    if @event.event_name_identifier == 'Family Update'
      SugarCRM::Operations::Families::HandleFamilyUpdate.new.call(@event.data, @event)

    elsif @event.event_name_identifier == 'Primary Subscriber Update'
      People::HandlePrimaryPersonUpdate.new.call(@event.data, @event)
    end
    head :ok
  end

  def archive 
    @event = Event.find(params[:id])
    @event.archive
    head :ok
  end
  
  def show
    @event = Event.find(params[:id])
  end
end