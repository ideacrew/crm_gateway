# frozen_string_literal: true

require 'aca_entities/crm/libraries/crm_library'

module Operations
  module Transformers
    # operation to transform a family entity into an outbound payload with an accounts and contacts
    class GenerateOutboundPayload
      include Dry::Monads[:result, :do, :try]

      def call(params)
        family_entity = yield validate(params)
        generate_outbound_payload(family_entity)
      rescue StandardError => e
        Failure("Failed to generate outbound payload: #{e.message} backtrace: #{e.backtrace.join("\n")}")
      end

      private

      def validate(params)
        # binding.irb
        return Success(params) if params.present?
        Failure("Inbound family entity not present")
      end

      def generate_outbound_payload(family_entity)
        account = ::AcaEntities::Crm::Transformers::FamilyTo::Account.new.call(family_entity)
        account.success? ? Success(account.value!) : Failure(account.failure)
      end
    end
  end
end
