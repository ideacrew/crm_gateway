# frozen_string_literal: true

# SubscribersFamiliesCreatedOrUpdatedSubscriber
module Subscribers
  module Families
    # Subscribe events for family create or update requests from enroll
    class CreatedOrUpdatedSubscriber
      include EventSource::Logging
      include ::EventSource::Subscriber[amqp: 'enroll.families']

      subscribe(:on_created_or_updated) do |delivery_info, metadata, response|
        subscriber_logger = subscriber_logger_for(:on_families_created_or_updated)
        payload = JSON.parse(response, symbolize_names: true)
        timestamps = metadata.headers.deep_symbolize_keys

        pre_process_message(subscriber_logger, payload, timestamps)
        result = process_families_created_or_updated(payload[:after_save_cv_family], timestamps)
        subscriber_logger.info { result.success? ? 'Success' : 'Failure' }

        ack(delivery_info.delivery_tag)
      rescue StandardError, SystemStackError => e
        subscriber_logger.error "FamiliesSubscriber::CreatedOrUpdated payload: #{payload}, error message: #{e.message}, backtrace: #{e.backtrace}"
        subscriber_logger.error "FamiliesSubscriber::CreatedOrUpdated, ack: #{payload}"
        ack(delivery_info.delivery_tag)
      end

      def pre_process_message(subscriber_logger, payload, headers)
        subscriber_logger.info "Headers: #{headers}"
        subscriber_logger.info "FamiliesSubscriber::CreatedOrUpdated, Family Hbx ID: #{family_hbx_id(payload)}, Primary Person Hbx ID: #{primary_person_hbx_id(payload)}"
      end

      # Retrieves the HBX ID of the primary person from the given payload.
      #
      # @param payload [Hash] The payload containing family information.
      # @return [String, nil] The HBX ID of the primary person, or nil if not found or if the payload is invalid.
      def primary_person_hbx_id(payload)
        return nil unless payload.is_a?(Hash)

        family_members = payload.dig(:after_save_cv_family, :family_members)
        return nil unless family_members.is_a?(Array)

        primary = family_members.detect { |member| member[:is_primary_applicant] == true }
        return nil unless primary.is_a?(Hash)

        primary[:hbx_id]
      end

      # Retrieves the HBX ID of the family from the given payload.
      #
      # @param payload [Hash] The payload containing family information.
      # @return [String, nil] The HBX ID of the family, or nil if not found or if the payload is invalid.
      def family_hbx_id(payload)
        return nil unless payload.is_a?(Hash)

        payload.dig(:after_save_cv_family, :hbx_id)
      end

      def process_families_created_or_updated(payload, timestamps)
        ::Operations::Families::CreatedOrUpdatedProcessor.new.call(
          {
            inbound_family_cv: payload,
            after_updated_at: timestamps[:after_updated_at]
          }
        )
      end

      def subscriber_logger_for(event)
        Logger.new(
          Rails.root.join("log", "#{event}_#{Time.zone.today.strftime('%Y_%m_%d')}.log")
        )
      end
    end
  end
end
