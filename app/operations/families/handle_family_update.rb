# frozen_string_literal: true

module Families
  # Invoke a Family update service and update/create their corresponding contact records
  class HandleFamilyUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'

    attr_reader :event

    # @return [Dry::Monads::Result]
    def call(family_payload)
      @event = Event.create(
        event_name_identifier: 'Family Update',
        data: family_payload
      )
      validated_payload = event_step(build_accounts_and_contacts(family_payload), 'process')
      event_step(publish_to_crm(validated_payload.value!), 'complete')
    end

    def event_step(result, state = nil)
      puts state.inspect
      if result.failure?
        @event.error_message = result.failure
        @event.fail!
      elsif state
        @event.send(state)
      end
      @event.save!
      result
    end

    protected

    def publish_to_crm(validated_payload)
      SugarCRM::Operations::FamilyUpsert.new.call(payload: validated_payload)
    end

    # Famlily Payload is a Hash
    def build_accounts_and_contacts(family_payload)
      result = Operations::Transformers::FamilyTo::AccountAndContacts.new.call(family_payload.to_h)
      if result.success?
        Success(result.to_h)
      else 
        Failure(result.errors.to_h)
      end
    end
  end
end
