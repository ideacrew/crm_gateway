# frozen_string_literal: true

module Families
  # Invoke a Family update service and update/create their corresponding contact records
  class HandleFamilyUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command

    # @return [Dry::Monads::Result]
    def call(payload)
      validated_family = yield validate_family(payload)
      initialized_contacts_and_accounts = build_accounts_and_contacts(validated_family)
      result = validate_contacts_and_accounts(initialized_contacts_and_accounts)
      Success(result)
    end

    protected

    def validate_family(payload)
      result = AcaEntities::Families::Family.new.call(payload.value!)
      result.success? ? result : Failure(result.failure.errors.to_h)
    end

    # This is from sugar CRM stuff
    def build_accounts_and_contacts(validated_family)
      initialized_contacts_and_accounts = Operations::Transformers::FamilyTo::AccountAndContacts.new.call(validated_family.value!)
    end

    def validate_contacts_and_accounts(initialized_contacts_and_accounts)

    end
  end
end
