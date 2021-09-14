# frozen_string_literal: true

module SugarCRM::Operations::Families
  # Invoke a Family update service and update/create their corresponding contact records
  class HandleFamilyUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command
    require File.join(Rails.root, 'app', 'operations', 'transformers', 'family_to', 'family_to_account_and_contacts')
    require 'dry/monads'
    require 'dry/monads/do'
    require 'aca_entities/crms/accounts/account'
    require 'aca_entities/crms/contracts/accounts/account_contract'
    require 'aca_entities/crms/contracts/contacts/contact_contract'
    require 'aca_entities/crms/contacts/contact'

    # @return [Dry::Monads::Result]
    def call(family_payload)
      @event = Event.create(
        event_name_identifier: 'Family Update',
        data: family_payload
      )
      initialized_contacts_and_accounts = build_accounts_and_contacts(family_payload)
      validated_payload = yield validate_contacts_and_accounts(initialized_contacts_and_accounts)
      result = yield publish_to_crm(validated_payload)
    end

    protected

    def publish_to_crm(validated_payload)
      SugarCrm::Operations::FamilyUpsert(validated_payload)
    end

    # Famlily Payload is a Hash
    def build_accounts_and_contacts(family_payload)
      Operations::Transformers::FamilyTo::AccountAndContacts.new.call(family_payload.to_h)
    end

    def validate_contacts_and_accounts(initialized_contacts_and_accounts)
      account_validation_and_contract_validation = Crms::Accounts::AccountContract.new.call(initialized_contacts_and_accounts)
    end
  end
end