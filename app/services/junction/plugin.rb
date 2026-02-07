# frozen_string_literal: true

require_relative "entity_scope"

module Junction
  # Represents a plugin within the application.
  class Plugin
    attr_reader :auth_providers, :icon, :name, :sidebar_links, :title

    # Initializes a new plugin.
    #
    # @param name [String] The unique name of the plugin.
    # @param namespace [Module] The namespace of the module, used to resolve
    #   constants.
    # @param icon [String] The primary icon associated with the plugin.
    # @param title [String] Optional, human-readable title for the plugin.
    def initialize(name, namespace, icon:, title: nil)
      @name = name
      @namespace = namespace
      @icon = icon
      @title = title || name.titleize

      @auth_providers = {}
      @entities = Hash.new { |h, k| h[k] = {} }
      @sidebar_links = []
    end

    # Registers the plugin with the global registry.
    def register
      Junction::PluginRegistry.register_plugin(self)
    end

    # Registers an authentication provider for the plugin.
    #
    # @param args [Array] Positional arguments to pass to the provider.
    # @param callback [Proc] A callback to find the user from the authentication
    #   data.
    # @param provider [Symbol] The unique name of the provider, if different from
    #   the plugin name.
    # @param icon [String] Optional icon associated with the provider.
    # @param title [String] Optional, human-readable title for the provider.
    # @param options [Hash] Additional options for the provider.
    def auth_provider(*args, callback:, provider: @name.to_sym, icon: @icon, title: @title, **options)
      @auth_providers[provider] = { provider:, callback:, args:, icon:, title:, options: }
    end

    # Registers a global sidebar link.
    #
    # @param action [String] The path the link points to.
    # @param title [String] The title of the sidebar link.
    # @param icon [String] The icon associated with the link.
    # @param disabled [Boolean] Whether the link should be disabled.
    def sidebar_link(action:, title: @title, icon: @icon, disabled: false)
      @sidebar_links << { action:, title:, icon:, disabled: }
    end

    # Creates a scoped registration for a specific entity context.
    #
    # @param context [String] Name of the entity class to scope registrations to.
    # @param condition [Proc] Optional condition to be applied to supported
    #   registrations.
    # @yieldparam [EntityScope] The scope for entity-specific registrations.
    def for_entity(context, condition = nil, &block)
      entity = EntityScope.new(self, context, condition)
      block.call(entity)

      @entities[context] = entity
    end

    # Routable actions grouped by their context class.
    #
    # @return [Hash<String, Array>] A hash mapping context class names to arrays of action
    #   definitions.
    def actions
      @entities.to_h { |context, entity| [ context, entity.actions ] }
    end

    # Retrieves all registered annotations for a given context.
    #
    # @param context [String] Name of the entity class to retrieve annotations
    #   for.
    # @return [Hash<String, Hash>] A hash of annotation definitions.
    def annotations_for(context)
      return {} unless @entities.key?(context)

      @entities[context].annotations
    end

    # Retrieves all registered UI components for a given context and slot.
    #
    # @param context [String] Name of the entity class to retrieve components
    #   for.
    # @param slot [Symbol] The slot on the page to retrieve components for.
    # @return [Array<Hash>] An array of component definitions.
    def components_for(context, slot)
      return [] unless @entities.key?(context)

      @entities[context].components_for(slot)
    end

    # Retrieves all registered tabs for a given context.
    #
    # @param context [String] Name of the entity class to retrieve tabs for.
    # @return [Array<Hash>] An array of tab definitions.
    def tabs_for(context)
      return [] unless @entities.key?(context)

      @entities[context].tabs
    end

    # Resolves a constant within the plugin's namespace.
    #
    # @param constant_name [String] The name of the constant to resolve.
    # @return [Class, Module] The resolved constant.
    def resolve(constant_name)
      @namespace.const_get(constant_name)
    end
  end
end
