module SugarCRM
  module Operations
    class CreateOrUpdateContact
      include Dry::Monads[:result, :do, :try]

      def call(hbx_id:, params:)
        existing_contact = find_existing_contact(hbx_id: hbx_id)
        results += [find_existing_contact: existing_contact]
        if existing_contact.success?
          self.id = extract_first_record_id(existing_contact.value!)
          updated_contact = update_contact(id, account_id, params)
          results += [update_contact: updated_contact]
        else
          created_contact = create_contact(account_id, params)
          results += [create_contact: created_contact]
        end

        if results.map(&:first).all? do |(step, result)|
          step =~ /create|update/ && result.success?
        end
          Success(results)
        else
          Failure(results)
        end
      rescue StandardError => e
        Failure(e)
      end

      def find_existing_contact(hbx_id:)
        response = service.filter_contacts([hbxid_c: hbx_id])
        if response.parsed['records'].empty?
          Success(response)
        else
          Failure(response)
        end
      end

      def create_contact(account_id, payload)
        yield service.create_contact(payload: payload.merge(account_id: account_id))
      end

      def update_contact(id, account_id, payload)
        yield service.update_contact(
          id: id,
          payload: payload.merge(account_id: account_id)
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