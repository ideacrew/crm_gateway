module SugarCRM
  module Operations
    class CreateOrUpdateAccount
      include Dry::Monads[:result, :do, :try]
      attr_reader :id

      def call(hbx_id:, params:)
        existing_account = find_existing_account(hbx_id: hbx_id)
        results = [find_existing_account: existing_account]

        if existing_account.success?
          @id = extract_first_record_id(existing_account.value!)
          updated_account = response_call { update_account(@id, params) }
          results += [update_account: updated_account]
        else
          created_account = response_call { create_account(params) }
          @id = extract_record_id(created_account.value!) if created_account.success?

          results += [create_account: created_account]
        end

        if results.map(&:first).all? do |(step, result)|
          step =~ /create|update/ && result.success?
        end
          Success(results)
        else
          Failure(results)
        end
      end

      def find_existing_account(hbx_id:)
        response = service.filter_accounts([hbxid_c: hbx_id])
        if response.parsed['records'].empty?
          Success(response)
        else
          Failure(response)
        end
      end

      def create_account(payload)
        yield service.create_account(payload: payload)
      end

      def update_account(id, payload)
        yield service.update_account(
          id: id,
          payload: payload
        )
      end

      def extract_first_record_id(response)
        response.parsed.dig('records', 0, 'id')
      end

      def extract_record_id(response)
        response.parsed['id']
      end

      def service
        @service ||= SugarCRM::Services::Connection.new
      end
    end
  end
end