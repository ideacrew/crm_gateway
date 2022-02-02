# frozen_string_literal: true

# class for Events Rails controller for managing events
class EventsController < ApplicationController
  def index
    @events = Event.where(updated_at: (Time.now - 1.hour)..Time.now).not.archived.order_by(updated_at: :desc).limit(200)
  end

  def show
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update params.require(:event).permit(:archived)
    #@event.update(event_params)

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

  private

  def event_params
    params.require(:event).permit(:archived)
  end
end