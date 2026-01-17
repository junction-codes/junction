# frozen_string_literal: true

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "rails_icons"
require "ransack"
require "tailwindcss-rails"

module Junction
  class Engine < ::Rails::Engine
    ENGINE_CONFIG_PATH = root.join("config", "junction.yml").freeze

    engine_name "junction"
    isolate_namespace Junction

    paths["config/routes.rb"] = [ "config/routes/engine.rb" ]

    initializer "junction.zeitwerk_ignore" do
      # Ignore our gems entrypoint file to avoid Zeitwerk warnings.
      Rails.autoloaders.main.ignore(root.join("lib/junction-codes.rb"))
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
      Junction.config = app.config_for(ENGINE_CONFIG_PATH)

      app_config_path = app.root.join("config", "junction.yml")
      if File.exist?(app_config_path)
        Junction.config.merge!(app.config_for(app_config_path))
      end
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

      # Junction::PluginLoader.load! unless Rails.env.test?
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
  end
end
