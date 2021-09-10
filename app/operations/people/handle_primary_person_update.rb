# frozen_string_literal: true

module Families
  # Invoke a primary subscriber person update service and update/create their corresponding contact records
  class HandlePrimaryPersonUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command
    require File.join(Rails.root, 'app', 'operations', 'transformers', 'person_to', 'persron_to_contact')
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'

    # @return [Dry::Monads::Result]
    def call(person_payload)
      # initialized_contact = yield build_contact(person_payload)
      validated_payload = yield validate_contact(initialized_contact)
      result = yield publish_to_crm(validated_payload)
      Success(result)
    end

    protected

    def publish_to_crm(validated_payload)
      SugarCrm::Operations::PrimaryPersonUpsert(validated_payload)
    end

    # Famlily Payload is a Hash
    def build_accounts_and_contacts(person_payload)
      initialized_contacts_and_accounts = Operations::Transformers::PersonTo::Contact.new.call(person_payload.to_h)
    end

    def validate_contacts_and_accounts(contact_payload)
      contact_validation = Crms::Contacts::ContactContract.new.call(contact_payload)
      Fail('Invalid contact') if contact_validation.failure?
    end
  end
end
