# frozen_string_literal: true

require "omniauth"

require_relative "../../app/services/junction/plugin_registry"

ActiveSupport.run_load_hooks(:junction_plugins)

Rails.application.config.middleware.use OmniAuth::Builder do
  ::Junction::PluginRegistry.auth_providers.each_value do |p|
    provider p[:provider], *p[:args], **p[:options]
  end
end
