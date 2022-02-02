# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"
require 'date'

include FormatHelper

module SugarCRM
  module Operations
    module Payload
      class Dob
        include Dry::Monads[:result, :do, :try]

        def call(dob)
          #convert to operation
          date = Date.parse(dob.to_s)
          Success(date.strftime("%Y-%m-%d"))
        rescue Date::Error
          Failure("Invalid DOB")
        rescue TypeError
          Failure("DOB not present")
        rescue StandardError => e
          Failure(e)
        end
      end
    end
  end
end
