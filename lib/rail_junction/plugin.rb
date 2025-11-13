# frozen_string_literal: true

module RailJunction
  # Provides a more convenient interface for plugin authors to register various
  # hooks and extensions within the system.
  #
  # Usage:
  #   RailJunction::Plugin.register "my-plugin-name" do |plugin|
  #     plugin.for_entity(::Component) do |component|
  #       component.annotation(...)
  #     end
  #   end
  class Plugin
    attr_reader :plugin_name

    # Registers a new plugin and yields for a block to define its hooks.
    #
    # @param name [String] The unique name of the plugin.
    # @yieldparam [RailJunction::Plugin] The plugin instance for registrations.
    def self.register(name, &)
      yield new(name)
    end

    # Initializes a new plugin instance.
    #
    # @param name [String] The unique name of the plugin.
    def initialize(name)
      @name = name
    end

    # Accesses the global plugin registry.
    #
    # @return [PluginRegistry] The plugin registry.
    def registry
      @registry ||= PluginRegistry.instance
    end

    # Creates a scoped registration for a specific entity class.
    #
    # @param context [Class] The entity class to scope registrations to.
    # @yieldparam [EntityRegistrationProxy] The proxy for entity-specific
    #   registrations.
    def for_entity(context, &)
      yield EntityRegistrationProxy.new(registry, context)
    end

    # Registers a global sidebar link.
    #
    # @param title [String] The title of the sidebar link.
    # @param action [String] The path the link points to.
    # @param icon [String] The icon associated with the link.
    # @param disabled [Boolean] Whether the link should be disabled.
    def sidebar_link(title:, action:, icon:, disabled: false)
      registry.register_sidebar_link(title:, action:, icon: icon, disabled:)
    end
  end

  # A proxy class to facilitate entity-specific registrations.
  class EntityRegistrationProxy
    attr_reader :registry, :context

    # Initializes a new registration proxy.
    #
    # @param registry [PluginRegistry] The plugin registry.
    # @param context [Class] The entity class context.
    def initialize(registry, context)
      @registry = registry
      @context = context
    end

    # Registers a new action for the entity context.
    #
    # @param method [Symbol] The route helper method for the action.
    # @param controller [String] The controller that handles the action (e.g.
    #   'rail_junction/plugin/action').
    # @param path [String] An optional custom path for the action.
    # @param action [Symbol] The action name in the controller.
    #
    # @see RailJunction::PluginRegistry#register_action
    def action(method:, controller:, path: nil, action: :index)
      @registry.register_action(context:, method:, controller:, path:, action:)
    end

    # Registers a new annotation for the entity context.
    #
    # @param key [String] The key for the annotation in the annotations hash.
    # @param title [String] The human-readable title of the annotation.
    # @param placeholder [String] An optional placeholder for the annotation in
    #   the UI.
    #
    # @see RailJunction::PluginRegistry#register_annotation
    def annotation(key:, title:, placeholder: nil)
      @registry.register_annotation(context:, key:, title:, placeholder:)
    end

    # Registers a new UI component for the entity context.
    #
    # @param slot [Symbol] The slot on the page the component should be rendered
    #   in.
    # @param component [Components::Base] THe component class to render.
    #
    # @see RailJunction::PluginRegistry#register_ui_component
    def component(slot:, component:)
      @registry.register_ui_component(context:, slot:, component:)
    end

    # Registers a new tab for the entity context.
    #
    # @param title [String] The title of the tab.
    # @param action [Symbol] The path method to link to when the tab is clicked.
    # @param icon [String] Icon to display alongside the tab title.
    # @param target [String] Turbo frame ID for the tab's content.
    # @param if [Proc] A conditional Proc that determines if the tab should be
    #   shown.
    #
    # @see RailJunction::PluginRegistry#register_tab
    def tab(title:, action:, icon: nil, target: nil, if: nil)
      @registry.register_tab(context:, title:, action:, icon:, target:, if:)
    end
  end
end
