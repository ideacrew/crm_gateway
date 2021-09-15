# frozen_string_literal: true

#Subscribes to the events stream
class EventsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'events'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
