# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"
require 'date'

module SugarCRM
  module Operations
    module Payload
      # HBX ID Operation
      class HbxId
        include Dry::Monads[:result, :do, :try]

        def call(payload)
          return Success(payload[:hbx_id]) if payload[:hbx_id]
          Failure("No HBX ID found")
        end
      end
    end
  end
end

