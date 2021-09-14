# frozen_string_literal: true

module Subscribers
  # Receive family updates published from Enroll
  class FamilyUpdateSubscriber
    include ::EventSource::Subscriber[amqp: 'crm_gateway.families']

    # rubocop:disable Lint/RescueException
    # rubocop:disable Style/LineEndConcatenation
    # rubocop:disable Style/StringConcatenation
    subscribe(:on_family_update) do |delivery_info, _properties, payload|
      family_update_result = ::SugarCRM::Operations::Families::HandleFamilyUpdate.new.call(payload)

      if family_update_result.success?
        logger.info(
          'OK: :family_update successful and acked'
        )
        ack(delivery_info.delivery_tag)
      else
        logger.error(
          "Error: :family_update; nacked due to:#{family_update_result.inspect}"
        )
        nack(delivery_info.delivery_tag)
      end

    rescue Exception => e
      logger.error(
        "Exception: :family_update\n Exception: #{e.inspect}" +
        "\n Backtrace:\n" + e.backtrace.join("\n")
      )
      nack(delivery_info.delivery_tag)
    end
    # rubocop:enable Lint/RescueException
    # rubocop:enable Style/LineEndConcatenation
    # rubocop:enable Style/StringConcatenation
  end
end
