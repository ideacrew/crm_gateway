# frozen_string_literal: true

module Subscribers
  # Receive family updates published from Enroll
  class PrimaryPersonSubscriber
    include ::EventSource::Subscriber[amqp: 'crm_gateway.people']

    # rubocop:disable Lint/RescueException
    # rubocop:disable Style/LineEndConcatenation
    # rubocop:disable Style/StringConcatenation
    subscribe(:on_primary_subscriber_update) do |delivery_info, _properties, payload|
      family_update_result = ::People::HandlePrimaryPersonUpdate.new.call(payload)

      if family_update_result.success?
        logger.info(
          'OK: :primary subscriber update successful and acked'
        )
        ack(delivery_info.delivery_tag)
      else
        logger.error(
          "Error: :primary subscriber update; nacked due to:#{family_update_result.inspect}"
        )
        nack(delivery_info.delivery_tag)
      end

    rescue Exception => e
      logger.error(
        "Exception: :primary subscriber update \n Exception: #{e.inspect}" +
        "\n Backtrace:\n" + e.backtrace.join("\n")
      )
      nack(delivery_info.delivery_tag)
    end
    # rubocop:enable Lint/RescueException
    # rubocop:enable Style/LineEndConcatenation
    # rubocop:enable Style/StringConcatenation
  end
end
