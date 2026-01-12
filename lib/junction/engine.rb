# frozen_string_literal: true

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "rails_icons"
require "tailwindcss-rails"

module Junction
  class Engine < ::Rails::Engine
    engine_name "junction"

    paths["config/routes.rb"] = [ "config/routes/engine.rb" ]

    initializer "junction.append_migrations" do |app|
      next if app.root.to_s == root.to_s

      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    initializer "junction.view_overrides" do |app|
      next if app.root.to_s == root.to_s

      host_views = app.root.join("app/views")
      ActiveSupport.on_load(:action_controller) do
        prepend_view_path(host_views)
      end
    end

    initializer "junction.component_overrides" do |app|
      next if app.root.to_s == root.to_s

      host_components = app.root.join("app/components").to_s
      config.autoload_paths.unshift(host_components) if Dir.exist?(host_components)
    end

    initializer "junction.asset_paths" do |app|
      asset_path = root.join("app/assets").to_s
      if app.config.respond_to?(:assets) && app.config.assets.paths.exclude?(asset_path)
        app.config.assets.paths << asset_path
      end
    end

    initializer "junction.configuration" do |app|
      # Allow host apps to configure Junction behavior
      app.config.junction = ActiveSupport::OrderedOptions.new unless app.config.respond_to?(:junction)
      app.config.junction.allow_demo_mode ||= ENV.fetch("JUNCTION_DEMO_MODE", "false") == "true"
    end

    initializer "junction.helpers", after: :load_config_initializers do |app|
      # Extend host app's helpers with turbo-rails and importmap-rails helpers
      # so Phlex components have access to these in view_context
      ActiveSupport.on_load(:action_controller_base) do
        helper Turbo::DriveHelper if defined?(Turbo::DriveHelper)
        helper Importmap::ImportmapTagsHelper if defined?(Importmap::ImportmapTagsHelper)
      end
    end

    initializer "junction.load_plugins", before: "junction.configuration" do |app|
      # Auto-load junction-plugins-* gems after the engine loads but before initializers
      next if app.root.to_s == root.to_s

      Junction::PluginLoader.load! unless Rails.env.test?
    end

    initializer "junction.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")

      # Add cache sweepers for development and testing.
      app.config.importmap.cache_sweepers << root.join("app/javascript")
      app.config.importmap.cache_sweepers << root.join("vendor/javascript")
    end

    initializer "junction.assets" do |app|
      # Add javascript files from the engine to the asset pipeline.
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.paths << root.join("vendor/javascript")
    end

    initializer "junction.tailwindcss" do |app|
      if defined?(Tailwindcss)
        # Add engine views to the host app's search path
        # app.config.tailwindcss.engines ||= []
        # app.config.tailwindcss.engines << Junction::Engine.engine_name
        app.config.tailwindcss.content << Junction::Engine.root.join("app/views/**/*")
        app.config.tailwindcss.content << Junction::Engine.root.join("app/helpers/**/*")
        app.config.tailwindcss.content << Junction::Engine.root.join("app/javascript/**/*")
      end
    end
  end
end
