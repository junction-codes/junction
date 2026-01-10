# frozen_string_literal: true

module Junction
  class Engine < ::Rails::Engine
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
  end
end
