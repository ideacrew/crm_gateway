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
    require_relative '../../domain/sugar_crm/operations/primary_upsert'

    attr_reader :event

    # @return [Dry::Monads::Result]
    def call(person_payload)
      # TODO: Coming through as a string on enroll for some reason
      if person_payload.class == String
        person_payload = JSON.parse(person_payload).with_indifferent_access
      end
      @event = Event.create(
        event_name_identifier: 'Primary Subscriber Update',
        data: person_payload
      )
      validated_payload = event_step(validate_contact(build_contact(person_payload)), 'process')
      event_step(publish_to_crm(person_payload), 'complete')
    end

    def event_step(result, state = nil)
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
      pp validated_payload
      SugarCRM::Operations::PrimaryUpsert.new.call(payload: validated_payload)
    end

    def build_contact(person_payload)
      {
        hbx_id: person_payload[:hbx_id],
        first_name: person_payload.dig(:person_name, :first_name),
        last_name: person_payload.dig(:person_name, :last_name),
        date_of_birth: person_payload.dig(:person_demographics, :dob),
        email: person_payload[:emails].detect { |email| email[:address].present? }.try(:[], :address),
        ssn: person_payload.dig(:person_demographics, :ssn),
        relationship_to_primary: "self"
      }
    end

    def validate_contact(contact_payload)
      result = AcaEntities::Crms::Contacts::ContactContract.new.call(contact_payload)
      if result.success?
        Success(result.to_h)
      else 
        Failure(result.errors.to_h)
      end
    end
  end
end
