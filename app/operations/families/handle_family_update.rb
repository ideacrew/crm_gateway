# frozen_string_literal: true

require File.join(Rails.root, "app", "operations", "transformers", "family_to", "family_to_account_and_contacts")
require 'aca_entities/liib/aca_entities/'

module Families
  # Invoke a Family update service and update/create their corresponding contact records
  class HandleFamilyUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command

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
      binding.irb
      result = Accounts::AccountContract.new.call(value)
    end
  end
end
