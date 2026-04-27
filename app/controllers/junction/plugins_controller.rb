# frozen_string_literal: true

module Junction
  # Controller for viewing installed plugins.
  class PluginsController < ApplicationController
    before_action :set_breadcrumbs
    before_action :set_plugins

    # GET /plugins
    def index
      authorize! :plugins

      render Views::Plugins::Index.new(
        core_plugins:,
        external_plugins:,
        breadcrumbs:
      )
    end

    private

    attr_reader :breadcrumbs, :core_plugins, :external_plugins

    # Builds the breadcrumb items for the page.
    #
    # The `Breadcrumbs` concern is designed to be used in model backed
    # controllers, which this controller is not. Therefore, we need to build
    # the breadcrumbs manually.
    def set_breadcrumbs
      @breadcrumbs ||= [
        { href: root_path, label: t("junction.breadcrumbs.home") },
        { href: plugins_path, label: t("junction.views.plugins.index.title") }
      ]
    end

    def set_plugins
      @core_plugins, @external_plugins = PluginRegistry.plugins.values.partition do |plugin|
        plugin == Junction::CorePlugin
      end
    end
  end
end
