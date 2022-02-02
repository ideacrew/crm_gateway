# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
#require_relative "../../sugar_crm/services/connection"
require 'date'

include FormatHelper

module SugarCRM
  module Operations
    module Payload
      class PhoneNumber
        include Dry::Monads[:result, :do, :try]

        def call(payload)
          mobile_phone = yield mobile_phone_finder(payload)
          phone_formatter(mobile_phone)
        end


        def mobile_phone_finder(payload)
          phone_number = payload.compact.detect { |number| valid_phone?(number) && number[:kind] == 'mobile' } ||
                         payload.compact.detect { |number| valid_phone?(number) && number[:kind] == 'home' } ||
                         valid_phone?(payload.first) ? payload.first : nil

          phone_number.present? ? Success(phone_number) : Failure("No valid phone number found")
        rescue StandardError => e
          Failure(e)
        end

        def valid_phone?(number)
          (number[:area_code] && number[:number]) || number[:full_number]
        end

        def phone_formatter(phone)
          if phone[:area_code] && phone[:number]
            Success("(#{phone[:area_code]}) #{phone[:number].first(3)}-#{phone[:number][3..-1]}")
          elsif phone[:full_number]&.length == 10
            Success("(#{phone[:full_number].first(3)}) #{phone[:full_number][3..5]}-#{phone[:full_number][6..-1]}")
          elsif phone[:full_number]
            Success(phone[:full_number])
          else
            Failure("No phone number found")
          end
        rescue StandardError => e
          Failure(e)
        end
      end
    end
  end
end
