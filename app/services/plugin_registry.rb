# frozen_string_literal: true

require "singleton"

class PluginRegistry
  include Singleton

  class << self
    delegate :annotations_for, :register_annotation,
             :register_routable_plugin_action, :register_sidebar_link,
             :register_tab, :register_ui_component,
             :routable_actions_grouped_by_context, :sidebar_links, :tabs_for,
             :ui_components_for,
             to: :instance
  end

  # Initialize the data structures to hold plugin registrations.
  def initialize
    @annotations = Hash.new { |h, k| h[k] = {} }
    @components = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
    @hooks = {
      tabs: Hash.new { |h, k| h[k] = [] },
      sidebar_links: []
    }
    @routable_actions = []
  end

  def register_annotation(context_class:, key:, title:, placeholder: nil)
    @annotations[context_class][key] = {
      key:,
      title:,
      placeholder:
    }
  end

  def register_sidebar_link(title:, path:, icon:, disabled: false)
    @hooks[:sidebar_links] << { title:, path:, icon:, disabled: }
  end

  def register_tab(context_class:, title:, component: nil, path_method: nil, icon: nil, target: nil)
    @hooks[:tabs][context_class.to_s] << {
      title:,
      path_method:,
      component:,
      icon:,
      target: target || path_method&.to_s&.gsub("_path", "") || title.parameterize
    }
  end

  def register_routable_plugin_action(context_class:, path_method:, controller:, path: nil, action: :index)
    @routable_actions << {
      context_class: context_class.to_s,
      path_method:,
      controller:,
      action:,
      path:
    }
  end

  # Registers a UI component to be rendered in a specific slot on a page.
  #
  # The current known slots are:
  #
  # - overview_cards
  #
  # @param context_class [Class] The model to add the component to.
  # @param slot [Symbol] The slot on the page the component should be rendered
  #   in.
  # @param component [Components::Base] THe component class to render.
  #
  # @todo Add validation to ensure the slot is valid for the given context.
  def register_ui_component(context_class:, slot:, component:)
    @components[context_class.name][slot.to_sym] << component
  end

  def annotations_for(context_class)
    @annotations[context_class]
  end

  def sidebar_links
    @hooks[:sidebar_links]
  end

  def tabs_for(context_object)
    @hooks[:tabs][context_object.class.to_s]
  end

  # Retrieves all registered UI components for a given context and slot.
  #
  # @param context [Class, ApplicationRecord] The model to retrieve components
  #   for.
  # @param slot [Symbol] The slot on the page to retrieve components for.
  # @return [Array<Components::Base>] An array of components to be rendered.
  def ui_components_for(context:, slot:)
    context = context.is_a?(Class) ? context : context.class
    @components[context.name][slot.to_sym]
  end

  def routable_actions_grouped_by_context
    @routable_actions.group_by { |action| action[:context_class] }
  end
end
