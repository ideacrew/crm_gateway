# frozen_string_literal: true

# The CrmGatewayRegistry is a registry object that is used to store configuration
# information for the EDI Gateway.
#
# @see ResourceRegistry::Registry
CrmGatewayRegistry = ResourceRegistry::Registry.new

# Configures the CrmGatewayRegistry with the given parameters.
#
# @param config [ResourceRegistry::Registry::Configuration] the configuration object
# @option config [Symbol] :name the name of the registry
# @option config [DateTime] :created_at the creation time of the registry
# @option config [String] :load_path the path to load the registry configuration from
CrmGatewayRegistry.configure do |config|
  config.name       = :crm_gateway
  config.created_at = DateTime.now
  config.load_path  = Rails.root.join('system/config/templates/features').to_s
end