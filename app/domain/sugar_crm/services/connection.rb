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
      
      def self.refresh_token
        @connection = connection.refresh! #should be truthy
      end

      delegate :get, :post, :put, :delete, to: 'self.class.connection'
      # [:get, :post, :put, :delete].each do |verb|
      #   define_method(verb) do |path, params|
      #     self.class.connection.send(verb, path, params)
      #   rescue => ExpiredToken #Oath Exception
      #     retry if self.class.refresh_token
      #   end
      # end

      def find_account_by_hbx_id(hbx_id)
        response = get('/rest/v11_8/Accounts', params: { filter: [{ hbxid_c: hbx_id }] })
        if response.parsed['records'].empty?
          false
        else 
          response.parsed['records'].first['id']
        end
      end

      def find_contact_by_hbx_id(hbx_id)
        response = get('/rest/v11_8/Contacts', params: { filter: [{ hbxid_c: hbx_id }] })
        if response.parsed['records'].empty?
          false
        else
          response.parsed['records'].first['id']
        end
      end

      def find_contacts_by_account(account_id)
        response = get('/rest/v11_8/Contacts', params: { filter: [{'accounts.id': account_id}] })
        response.parsed
      end

      def create_account(hbx_id:, first_name:, last_name:)
        response = post('/rest/v11_8/Accounts',
          params: {
            hbxid_c: hbx_id,
            name: "#{first_name} #{last_name}"
          }
        )
        response.parsed
      end

      def create_contact_for_account(account_id:, hbx_id:, first_name:, last_name:)
        response = post(
          '/rest/v11_8/Contacts',
          params: {
            'account.id': account_id,
            hbxid_c: hbx_id,
            first_name: first_name,
            last_name: last_name
          }
        )
        response.parsed
      end

      def update_account(hbx_id:, first_name:, last_name:)
        account = find_account_by_hbx_id(hbx_id)
        response = put(
          "/rest/v11_8/Accounts/#{account}",
          params: {
            name: "#{first_name} #{last_name}"
          }
        )
        response.parsed
      end

      def update_contact_by_hbx_id(hbx_id:, first_name:, last_name:) #change spec
        contact = find_contact_by_hbx_id(hbx_id)
        response = put(
          "/rest/v11_8/Contacts/#{contact}",
          params: {
            first_name: first_name,
            last_name: last_name,
          }
        )
        response.parsed
      end

      def update_contact(id:, first_name:, last_name:)
        response = put(
          "/rest/v11_8/Contacts/#{id}",
          params: {
            first_name: first_name,
            last_name: last_name,
          }
        )
        response.parsed
      end
    end
  end
end