# frozen_string_literal: true

module Junction
  # Controller for viewing installed plugins.
  class PluginsController < ApplicationController
    before_action :set_breadcrumbs

    # GET /plugins
    def index
      authorize! :plugins

      render Views::Plugins::Index.new(
        overview: Junction::Plugins::Overview.new,
        breadcrumbs:
      )
    end

    private

    attr_reader :breadcrumbs

    # Builds the breadcrumb items for the page.
    #
    # The `Breadcrumbs` concern is designed to be used in model backed
    # controllers, which this controller is not. Therefore, we need to build
    # the breadcrumbs manually.
    def set_breadcrumbs
      @breadcrumbs ||= [
        { href: root_path, label: t("junction.breadcrumbs.home") },
        { label: t("junction.breadcrumbs.settings") },
        { href: plugins_path, label: t("junction.views.plugins.index.title") }
      ]
    end
  end
end
