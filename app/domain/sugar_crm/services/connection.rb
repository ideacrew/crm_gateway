# frozen_string_literal: true

require 'oauth2'

module SugarCRM
  module Services
    # app/services/sugar_crm/connection.rb

    # Service class to create, maintain and utiltize a connection to SugarCRM
    class Connection
      def self.connection
        host, username, password = Rails.application.config.sugar_crm.values_at(:host, :username, :password)
        @client ||= OAuth2::Client.new('sugar', '', site: "https://#{host}", token_url: '/rest/v11_8/oauth2/token')
        @connection ||= @client.password.get_token(username, password,
          params: {
            username: username,
            password: password,
            grant_type: 'password',
            platform: 'mobile'
          }
        )
      end

      delegate :get, :post, :put, :delete, to: 'self.class.connection'

      def find_account_by_name(name)
        response = get('/rest/v11_8/Accounts', params: { filter: [{ name: name }] })
        response.parsed
      end

      def find_contacts_by_account(account_id)
        response = get('/rest/v11_8/Contacts', params: { filter: [{'accounts.id': account_id}] })
        response.parsed
      end

      def create_account(first_name:, last_name:)
        response = post('/rest/v11_8/Accounts', params: { name: "#{first_name} #{last_name}"})
        response.parsed
      end

      def create_contact_for_account(account_id:, first_name:, last_name:)
        response = post(
          '/rest/v11_8/Contacts',
          params: {
            'account.id': account_id,
            first_name: first_name,
            last_name: last_name
          }
        )
        response.parsed
      end
    end
  end
end