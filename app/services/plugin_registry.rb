# frozen_string_literal: true

require "singleton"

# Registry for managing plugin hooks into the application.
class PluginRegistry
  include Singleton

  class << self
    # Delegate class methods to the singleton instance.
    delegate :actions_grouped_by_context, :annotations_for,
             :register_action, :register_annotation, :register_sidebar_link,
             :register_tab, :register_ui_component, :sidebar_links, :tabs_for,
             :ui_components_for,
             to: :instance
  end

  # Initialize the data structures to hold plugin registrations.
  def initialize
    @annotations = Hash.new { |h, k| h[k] = {} }
    @components = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
    @tabs = Hash.new { |h, k| h[k] = [] }
    @sidebar_links = []
    @actions = []
  end

  # Register a routable action for a given context.
  #
  # @param context [Class] The model to add the action to.
  # @param method [Symbol] The route helper method for the action.
  # @param controller [String] The controller that handles the action (e.g.
  #   'rail_junction/plugin/action').
  # @param path [String] An optional custom path for the action.
  # @param action [Symbol] The action name in the controller.
  def register_action(context:, method:, controller:, path: nil, action: :index)
    @actions << {
      context_class: context_class(context).to_s,
      method:,
      controller:,
      action:,
      path:
    }
  end

  # Register an annotation for a given context.
  #
  # @param context [Class] The model to add the annotation to.
  # @param key [String] The key for the annotation in the annotations hash.
  # @param title [String] The human-readable title of the annotation.
  # @param placeholder [String] An optional placeholder for the annotation in
  #   the UI.
  def register_annotation(context:, key:, title:, placeholder: nil)
    @annotations[context_class(context)][key] = {
      key:,
      title:,
      placeholder:
    }
  end

  # Register a link to be displayed in the application sidebar.
  #
  # @param title [String] The title of the sidebar link.
  # @param action [String] The path method to link to when the tab is clicked.
  # @param icon [String] The icon to display alongside the link.
  # @param disabled [Boolean] Whether the link should be disabled.
  def register_sidebar_link(title:, action:, icon:, disabled: false)
    @sidebar_links << { title:, action:, icon:, disabled: }
  end

  # Register a tab to be displayed in the UI for entities.
  #
  # @param context [Class] The model to add the tab to.
  # @param title [String] The title of the tab.
  # @param action [Symbol] The path method to link to when the tab is clicked.
  # @param icon [String] Icon to display alongside the tab title.
  # @param target [String] Turbo frame ID for the tab's content.
  # @param if [Proc] A conditional Proc that determines if the tab should be
  #   shown.
  def register_tab(context:, title:, action:, icon: nil, target: nil, if: nil)
    @tabs[context_class(context).to_s] << {
      title:,
      action:,
      icon:,
      if:,
      target: target || action&.to_s&.gsub("_path", "") || title.parameterize
    }
  end

  # Registers a UI component to be rendered in a specific slot on a page.
  #
  # The current known slots are:
  #
  # - overview_cards
  # - user_profile_cards
  #
  # @param context [Class] The model to add the component to.
  # @param slot [Symbol] The slot on the page the component should be rendered
  #   in.
  # @param component [Components::Base] THe component class to render.
  # @param if [Proc] A conditional Proc that determines if the component
  #   should be rendered.
  #
  # @todo Add validation to ensure the slot is valid for the given context.
  def register_ui_component(context:, slot:, component:, if: nil)
    @components[context_class(context).name][slot.to_sym] << { component:, if: }
  end

  # Routable actions grouped by their context class.
  #
  # @return [Hash] A hash mapping context class names to arrays of action
  #   definitions.
  def actions_grouped_by_context
    @actions.group_by { |action| action[:context_class] }
  end

  # Retrieves all registered annotations for a given context.
  #
  # @param context [Class, ApplicationRecord] The model to retrieve annotations
  #   for.
  # @return [Hash] A hash of annotation definitions.
  def annotations_for(context)
    @annotations[context_class(context)]
  end

  # Retrieves all registered sidebar links.
  #
  # @return [Array<Hash>] An array of sidebar link definitions.
  def sidebar_links
    @sidebar_links
  end

  # Retrieves all registered tabs for a given context.
  #
  # @param context [Class, ApplicationRecord] The model to retrieve tabs for.
  # @return [Array<Hash>] An array of tab definitions.
  def tabs_for(context)
    @tabs[context_class(context).to_s]
  end

  # Retrieves all registered UI components for a given context and slot.
  #
  # @param context [Class, ApplicationRecord] The model to retrieve components
  #   for.
  # @param slot [Symbol] The slot on the page to retrieve components for.
  # @return [Array<Hash>] An array of component definitions.
  def ui_components_for(context:, slot:)
    @components[context_class(context).name][slot.to_sym]
  end

  private

  # Converts a context object or class into its class.
  #
  # @param context [Class, ApplicationRecord] The context to get the class of.
  # @return [Class] The class of the context.
  def context_class(context)
    context.is_a?(Class) ? context : context.class
  end
end
