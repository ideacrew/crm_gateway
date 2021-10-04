# frozen_string_literal: true

require 'oauth2'

module SugarCRM
  module Services
    # app/services/sugar_crm/connection.rb

    # Service class to create, maintain and utiltize a connection to SugarCRM
    class Connection
      def self.connection(force: false)
        host, username, password = Rails.application.config.sugar_crm.values_at(:host, :username, :password)
        @client ||= OAuth2::Client.new('sugar', '', site: "https://#{host}", token_url: '/rest/v11_8/oauth2/token')
        if @connection || !force
          @connection = @client.password.get_token(username, password,
                                                   params: {
                                                     username: username,
                                                     password: password,
                                                     grant_type: 'password',
                                                     platform: 'mobile'
                                                   })
        else
          @connection
        end
        @connection
      end

      #delegate :get, :post, :put, :delete, to: 'self.class.connection'
      [:get, :post, :put, :delete].each do |verb|
        define_method(verb) do |path, params|
          tries ||= 1
          self.class.connection.send(verb, path, params)
        rescue Faraday::Error
          tries += 1
          retry if tries < 3 && self.class.connection(force: true)
        end
      end

      def find_account_by_hbx_id(hbx_id)
        response = get('/rest/v11_8/Accounts', params: { filter: [{ hbxid_c: hbx_id }] })
        if response.parsed['records'].empty?
          false
        else
          response.parsed['records'].try(:first).try(:[], 'id')
        end
      end

      def find_contact_by_hbx_id(hbx_id)
        response = get('/rest/v11_8/Contacts', params: { filter: [{ hbxid_c: hbx_id }] })
        if response.parsed['records'].empty?
          false
        else
          response.parsed['records'].try(:first).try(:[], 'id')
        end
      end

      def create_account(payload:)
        response = post(
          '/rest/v11_8/Accounts',
          body: payload.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        response.parsed
      end

      def create_contact_for_account(payload:)
        response = post(
          '/rest/v11_8/Contacts',
          body: payload.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        response.parsed
      end

      # pass name
      def update_account(hbx_id:, payload:)
        account = find_account_by_hbx_id(hbx_id)
        response = put(
          "/rest/v11_8/Accounts/#{account}",
          body: payload.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        response.parsed
      end

      # change spec
      def update_contact_by_hbx_id(hbx_id:, payload:)
        contact = find_contact_by_hbx_id(hbx_id)
        response = put(
          "/rest/v11_8/Contacts/#{contact}",
          body: payload.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        response.parsed
      end

      def update_contact(id:, payload:)
        response = put(
          "/rest/v11_8/Contacts/#{id}",
          body: payload.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        response.parsed
      end
    end
  end
end