# frozen_string_literal: true

# class for Events Rails controller for managing events
class EventsController < ApplicationController
  def index
    @events = Event.not.archived.order_by(updated_at: :desc).limit(200)
  end

  def show
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update params.require(:event).permit(:archived)

    head :ok
  end

  def retry
    @event = Event.find(params[:id])
    @event.retry!
    case @event.event_name_identifier
    when 'Family Update'
      SugarCRM::Operations::Families::HandleFamilyUpdate.new.call(@event.data, @event)
    when 'Primary Subscriber Update'
      People::HandlePrimaryPersonUpdate.new.call(@event.data, @event)
    end

    head :ok
  end

  def archived
    @events = Event.archived.order_by(updated_at: :desc).limit(200)
  end

  def archive
    Event.not.archived.each(&:archive!)

    head :ok
  end
end