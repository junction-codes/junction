# frozen_string_literal: true

module Junction
  # Builds breadcrumb items for the current controller action.
  module Breadcrumbs
    extend ActiveSupport::Concern

    included do
      before_action :set_breadcrumbs
      attr_reader :breadcrumbs
    end

    private

    # Set the breadcrumb items on the current controller instance.
    #
    # @return [Array<Hash>] The breadcrumb items.
    def set_breadcrumbs
      @breadcrumbs = build_breadcrumb_items
    end

    # Build the breadcrumb items for the current controller action.
    #
    # @return [Array<Hash>] The breadcrumb items.
    def build_breadcrumb_items
      action = normalized_action

      [ breadcrumb_home ].tap do |items|
        items << breadcrumb_index
        items << breadcrumb_show if %i[show edit].include?(action)

        items << breadcrumb_new if action == :new
        items << breadcrumb_edit if action == :edit
      end
    end

    # Normalize the action name to a symbol.
    #
    # @return [Symbol] The normalized action name.
    def normalized_action
      case action_name.to_s
      when "create" then :new
      when "update" then :edit
      else action_name.to_sym
      end
    end

    # Get the model name from the controller name using I18n.
    #
    # @return [String] The model name.
    def model_name
      t("activerecord.models.#{controller_name.singularize.to_sym}.other")
    end

    # Build the breadcrumb item for the home page.
    #
    # @return [Hash] The breadcrumb item.
    def breadcrumb_home
      { href: root_path, label: t("breadcrumbs.home") }
    end

    # Build the breadcrumb item for the index page.
    #
    # @return [Hash] The breadcrumb item.
    def breadcrumb_index
      {
        href: send(:"#{controller_name}_path"),
        label: model_name
      }
    end

    # Build the breadcrumb item for the show page.
    #
    # @return [Hash] The breadcrumb item.
    def breadcrumb_show
      {
        href: send(:"#{controller_name.singularize}_path", @entity),
        label: @entity.respond_to?(:display_name) ? @entity.display_name : @entity.name
      }
    end

    # Build the breadcrumb item for the edit page.
    #
    # @return [Hash] The breadcrumb item.
    def breadcrumb_edit
      { label: t("breadcrumbs.edit") }
    end

    # Build the breadcrumb item for the new page.
    #
    # @return [Hash] The breadcrumb item.
    def breadcrumb_new
      {
        label: t("breadcrumbs.new", model: model_name)
      }
    end
  end
end
