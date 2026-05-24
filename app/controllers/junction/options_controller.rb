# frozen_string_literal: true

module Junction
  # Controller for catalog options.
  class OptionsController < ApplicationController
    before_action :set_breadcrumbs

    # GET /options
    def index
      authorize! :options
      set_option_fields

      render Views::Options::Index.new(breadcrumbs:, fields: option_fields)
    end

    private

    attr_reader :breadcrumbs, :option_fields

    # Builds the breadcrumb items for the page.
    #
    # The `Breadcrumbs` concern is designed for model-backed controllers.
    # This controller is not model-backed, so breadcrumbs are built directly.
    def set_breadcrumbs
      @breadcrumbs ||= [
        { href: root_path, label: t("junction.breadcrumbs.home") },
        { href: options_path, label: t("junction.views.options.index.title") }
      ]
    end

    # Builds the breakdowns of known and other options for the page.
    #
    # @return [Array<Hash>] Array of option fields.
    def set_option_fields
      @option_fields ||= Junction::Options::Overview.new.fields
    end
  end
end
