# frozen_string_literal: true

require Rails.root.join("app/services/plugin_registry")
require Rails.root.join("app/services/plugin")
require Rails.root.join("app/services/entity_scope")

ActiveSupport.run_load_hooks(:junction_plugins)

Rails.application.config.middleware.use OmniAuth::Builder do
  PluginRegistry.auth_providers.each_value do |p|
    provider p[:provider], *p[:args], **p[:options]
  end
end
