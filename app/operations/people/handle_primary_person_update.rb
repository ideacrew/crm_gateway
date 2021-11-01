# frozen_string_literal: true

module People
  # Invoke a primary subscriber person update service and update/create their corresponding contact records
  class HandlePrimaryPersonUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'
    require_relative "../../domain/sugar_crm/operations/primary_upsert"

    attr_reader :event_log

    # @return [Dry::Monads::Result]
    def call(person_payload, event_retry = nil)
      Rails.logger.debug { "event log #{@event_log}" }
      # TODO: Coming through as a string on enroll for some reason
      person_payload = JSON.parse(person_payload).with_indifferent_access if person_payload.instance_of?(String)
      @event_log = event_retry || Event.create(
        event_name_identifier: 'Primary Subscriber Update',
        data: person_payload
      )
      @event_log.process!
      result = publish_to_crm(person_payload)
      if result.success?
        @event_log.complete!
        Success("Updated the primary subscriber")
      else
        @event_log.error = result.failure[:error]
        @event_log.error_message = result.failure[:error_message]
        @event_log.error_backtrace = result.failure[:error_backtrace]
        @event_log.fail!
      end
      result
    end

    protected

    def publish_to_crm(validated_payload)
      SugarCRM::Operations::PrimaryUpsert.new.call(payload: validated_payload)
    end
  end
end
