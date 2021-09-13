# frozen_string_literal: true

module People
  # Invoke a primary subscriber person update service and update/create their corresponding contact records
  class HandlePrimaryPersonUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command
    require File.join(Rails.root, 'app', 'operations', 'transformers', 'person_to', 'person_to_contact')
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'
    require_relative "../../domain/sugar_crm/operations/primary_upsert"

    # @return [Dry::Monads::Result]
    def call(person_payload)
      initialized_contact = build_contact(person_payload)
      validated_payload = yield validate_contact(initialized_contact)
      result = yield publish_to_crm(validated_payload)
      Success(result)
    end

    protected

    def publish_to_crm(validated_payload)
      Operations::SugarCrm::PrimaryUpsert.new.call(validated_payload)
    end

    def build_contact(person_payload)
      Operations::Transformers::PersonTo::Contact.new.call(person_payload.to_h)
    end

    def validate_contact(contact_payload)
      Crms::Contacts::ContactContract.new.call(contact_payload)
    end
  end
end
