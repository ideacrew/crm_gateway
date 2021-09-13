require 'dry/monads'
require 'dry/monads/do'
require_relative "../../sugar_crm/services/connection"

module Operations
  module SugarCrm
    class PrimaryUpsert
      include Dry::Monads[:result, :do, :try]

      attr_accessor :event

      def call(params)
        @event = ::Event.create(event_name_identifier: self.class.name.to_s)
        existing_account = find_existing_account(
          first_name: params[:first_name],
          last_name: params[:last_name]
        )
        if existing_account.success?
          event.process
          yield update_account_and_contact(

          )
        else
          event.process
          yield create_account_and_contact(

          )
        end
        # event.complete # If this completes
      end

      def find_existing_account(first_name:, last_name:)
        if existing_account = service.find_existing_account(params.slice(:first_name, :last_name))
          Success(existing_account)
        else
          Fail("No account found")
        end
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end
