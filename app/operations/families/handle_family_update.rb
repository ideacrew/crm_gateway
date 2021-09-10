# frozen_string_literal: true

module Families
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
      initialized_contacts_and_accounts = build_accounts_and_contacts(family_payload)
      result = validate_contacts_and_accounts(initialized_contacts_and_accounts)
      Success(result)
    end

    protected

    # Famlily Payload is a Hash
    def build_accounts_and_contacts(family_payload)
      initialized_contacts_and_accounts = Operations::Transformers::FamilyTo::AccountAndContacts.new.call(family_payload.to_h)
    end

    def validate_contacts_and_accounts(initialized_contacts_and_accounts)
      # result = AcaEntities::Crms::Accounts::AccountContract.new.call(value)
      account_params = initialized_contacts_and_accounts.except(:contacts)
      account_validation = Crms::Accounts::AccountContract.new.call(account_params)
      raise('Invalid account') if account_validation.failure?

      contact_params = initialized_contacts_and_accounts[:contacts]
      contact_params.each do |contact_hash|
        contact_validation = Crms::Contacts::ContactContract.new.call(contact_hash)
        raise('Invalid contact') if contact_validation.failure?
      end
    end
  end
end
