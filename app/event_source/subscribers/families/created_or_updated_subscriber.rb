# frozen_string_literal: true

# SubscribersFamiliesCreatedOrUpdatedSubscriber
module Subscribers
  module Families
    # Subscribe events for family create or update requests from enroll
    class CreatedOrUpdatedSubscriber
      include EventSource::Logging
      include ::EventSource::Subscriber[amqp: 'enroll.families']

      subscribe(:on_created_or_updated) do |delivery_info, _properties, response|
        subscriber_logger = subscriber_logger_for(:on_families_created_or_updated)
        payload = JSON.parse(response, symbolize_names: true)

        pre_process_message(subscriber_logger, payload)

        ack(delivery_info.delivery_tag)
      rescue StandardError, SystemStackError => e
        subscriber_logger.error "FamiliesSubscriber::CreatedOrUpdated payload: #{payload}, error message: #{e.message}, backtrace: #{e.backtrace}"
        subscriber_logger.error "FamiliesSubscriber::CreatedOrUpdated, ack: #{payload}"
        ack(delivery_info.delivery_tag)
      end

      def pre_process_message(subscriber_logger, payload)
        subscriber_logger.info "FamiliesSubscriber::CreatedOrUpdated, response: #{payload}"
      end

      def subscriber_logger_for(event)
        Logger.new(
          Rails.root.join("log", "#{event}_1_#{Time.zone.today.strftime('%Y_%m_%d')}.log")
        )
      end
    end
  end
end