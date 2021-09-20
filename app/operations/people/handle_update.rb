# frozen_string_literal: true

module People
  # Invoke a primary subscriber person update service and update/create their corresponding contact records
  class HandleUpdate
    include Dry::Monads[:result, :do, :try]
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'
    require_relative "../../domain/sugar_crm/operations/primary_upsert"

    def initialize(event:)
      @event = event
    end

    # @return [Dry::Monads::Result]
    def call(payload)
      Rails.logger.debug { "event log #{@event}" }
      payload = JSON.parse(payload).with_indifferent_access if payload.instance_of?(String)
      @event.process!
      results = publish_to_crm(payload)
      results.value_or(results.failure).each do |step_monad|
        step, result = step_monad.first
        action = @event.actions.build(kind: step, success: result.success?)

        response = result.value_or(result.failure)
        if response.is_a?(Exception)
          action.exception = {
            backtrace: response.backtrace,
            class_name: response.class.name,
            message: response.message
          }
        else
          action.url = response.response.env.url
          action.incoming_payload = response.parsed
          action.outgoing_payload = JSON.parse(response.response.env.request_body) if response.response.env.request_body
        end
      end
          
      if results.success?
        @event.complete!
        Success("Update the family")
      else
        @event.fail!
        Failure("Couldn't Update the Family")
      end
    end

    protected

    def publish_to_crm(payload)
      case @event.event_name_identifier
      when "Primary Subscriber Update"
        SugarCRM::Operations::PrimaryUpsert.new.call(payload: payload)
      when "Family Update"
        SugarCRM::Operations::FamilyUpsert.new.call(payload: payload)
      end
    end
  end
end
