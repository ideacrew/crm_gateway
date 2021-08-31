# frozen_string_literal: true

module Families
  # Invoke a Family update service and update/create their corresponding contact records
  class HandleFamilyUpdate
    include Dry::Monads[:result, :do, :try]
    include EventSource::Command

    # @return [Dry::Monads::Result]
    def call(params)
      modified_family = yield parse_and_build_family(params[:payload])
      event  = yield build_event(params[:correlation_id], modified_family)
      result = yield publish(event)

      Success(result)
    end

    protected

    def parse_and_build_family(json_string)
      parsing_result = Try do
        JSON.parse(json_string, symbolize_names: true)
      end

      if parsing_result.success?
        result = AcaEntities::Families::Family.new.call(parsing_result.value!)
        result.success? ? result : Failure(result.failure.errors.to_h)
      else
        Failure(:invalid_json)
      end
    end

    def build_event(modified_family)
      payload = modified_family.to_h

      event(
        'sugar_crm.families.family_records',
        attributes: payload,
        headers: { correlation_id: correlation_id }
      )
    end

    def publish(event)
      event.publish

      Success('Family Update response published successfully')
    end
  end
end
