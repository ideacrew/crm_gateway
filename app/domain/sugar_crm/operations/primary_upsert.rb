require 'dry/monads'
require 'dry/monads/do'

module Operations
  module SugarCRM
    class PrimaryUpsert
      include Dry::Monads[:result, :do, :try]

      def call(params)
        existing_account = find_existing_account(
          first_name: params[:first_name],
          last_name: params[:last_name]
        )
        if existing_account.success?
          yield update_account_and_contact(

          )
        else
          yield create_account_and_contact(

          )
        end
      end

      def find_existing_account(first_name:, last_name:)
        if existing_account = service.find_existing_account(params.slice(:first_name, :last_name))
          Success(existing_account)
        else
          Fail("No account found")
        end
      end

      def service
        @service ||= Services::SugarCRM::Connection.new
      end
    end
  end
end
