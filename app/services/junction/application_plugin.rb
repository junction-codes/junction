# frozen_string_literal: true

require_relative "entity_scope"

module Junction
  # Base class for plugins.
  #
  # Plugins are defined as subclasses and configured at class definition time
  # using class-level DSL methods.
  #
  # @example Defining a plugin
  #   class MyPlugin::Plugin < Junction::ApplicationPlugin
  #     plugin_name "my_plugin"
  #     domain "my.plugin"
  #     title "My Plugin"
  #     icon "puzzle"
  #
  #     sidebar_link action: :my_plugin_root_path
  #
  #     for_entity "Junction::Api" do |s|
  #       s.annotation key: "my.plugin/owner", title: "Owner"
  #     end
  #   end
  #
  #   MyPlugin::Plugin.register
  class ApplicationPlugin
    DEFAULT_ICON = "toy-brick"
    PLUGIN_NAME_REGEXP = /\A[a-z][a-z0-9_-]+\z/

    # Every plugin that has registered, by plugin name.
    #
    # Held on the base class so the registry can be rebuilt after a code
    # reload since the initializer that registered a plugin does not run again.
    #
    # A later registration under the same name replaces the earlier one, which
    # is what a reload produces.
    @registrations = {}

    # @!group Plugin Identity DSL

    # Gets or sets the machine-readable plugin name.
    #
    # This name must match the format `/[a-z][a-z0-9_-]+/` and be unique across
    # all registered plugins.
    #
    # @param value [String, nil] The name to set, or nil to get.
    # @return [String]
    def self.plugin_name(value = nil)
      value ? @plugin_name = value : @plugin_name
    end

    # Gets or sets the domain this plugin belongs to.
    #
    # Multiple plugins can share the same domain.
    #
    # @param value [String, nil] The domain to set, or nil to get.
    # @return [String]
    def self.domain(value = nil)
      value ? @domain = value : @domain
    end

    # Gets or sets the primary icon for this plugin.
    #
    # @param value [String, nil] The icon to set, or nil to get.
    # @return [String]
    def self.icon(value = nil)
      value ? @icon = value : @icon || DEFAULT_ICON
    end

    # Gets or sets the human-readable title for this plugin.
    #
    # Defaults to {plugin_name}.titleize when not explicitly set.
    #
    # @param value [String, nil] The title to set, or nil to get.
    # @return [String]
    def self.title(value = nil)
      value ? @title = value : (@title || plugin_name&.titleize)
    end

    # Gets or sets an optional description for this plugin.
    #
    # @param value [String, nil] The description to set, or nil to get.
    # @return [String]
    def self.description(value = nil)
      value ? @description = value : @description
    end

    # @!endgroup

    # @!group Global Hook DSL

    # Registers a permission.
    #
    # @param context [String, Symbol] Context within the domain that the
    #   permission applies to.
    # @param ownership [Symbol] Ownership scope, one of `:all` or `:owned`.
    # @param access [Symbol] Access level, one of `:read`, `:write`, or
    #   `:destroy`.
    # @param description [String] Optional description of the permission.
    def self.permission(context:, ownership:, access:, description: "")
      @permission_definitions ||= []
      @permission_definitions << { context:, ownership:, access:, description: }
    end

    # Registers an authentication provider.
    #
    # @param args [Array] Positional arguments to pass to the OmniAuth provider.
    # @param callback [Proc] A callback to find the user from auth data.
    # @param provider [Symbol] The provider name; defaults to plugin_name.
    # @param icon [String] Icon for the provider; defaults to plugin icon.
    # @param title [String] Title for the provider; defaults to plugin title.
    # @param options [Hash] Additional OmniAuth options.
    def self.auth_provider(*args, callback:, provider: nil, icon: nil,
                           title: nil, **options)
      provider ||= plugin_name.to_sym
      @auth_providers ||= {}
      @auth_providers[provider] = {
        provider:,
        callback:,
        args:,
        icon: icon || self.icon,
        title: title || self.title,
        options:
      }
    end

    # Registers a sidebar link for the application.
    #
    # @param action [String] Rails route helper method for the action.
    # @param title [String] Link title; defaults to plugin title.
    # @param icon [String] Link icon; defaults to plugin icon.
    # @param disabled [Boolean] Whether the link is disabled.
    def self.sidebar_link(action:, title: nil, icon: nil, disabled: false)
      @sidebar_links ||= []
      @sidebar_links << {
        action:,
        title: title || self.title,
        icon: icon || self.icon,
        disabled:
      }
    end

    # Registers an item in the sidebar settings menu.
    #
    # @param action [String, Symbol] Rails route helper method or literal path.
    # @param title [String] Item title.
    # @param title_i18n [String] I18n key for title lookup at render time.
    # @param icon [String] Item icon; defaults to plugin icon.
    # @param disabled [Boolean] Whether the item is disabled.
    # @param access [Hash] Optional access requirements.
    # @option access [Symbol] :action Policy action to check.
    # @option access [Object] :record Policy record to authorize against.
    # @option access [Class] :with Optional policy class override.
    #
    # @raise [ArgumentError] If neither title nor title_i18n is provided.
    def self.settings_menu_item(action:, title: nil, title_i18n: nil, icon: nil,
                                disabled: false, access: nil)
      if title.blank? && title_i18n.blank?
        raise ArgumentError, "Settings menu items require either title or title_i18n"
      end

      @settings_menu_items ||= []
      @settings_menu_items << {
        action:,
        title: title,
        title_i18n:,
        icon: icon || self.icon,
        disabled:,
        access:
      }
    end

    # @!endgroup

    # @!group Entity-Scoped Hook DSL

    # Creates a scoped registration for a specific entity context.
    #
    # The block is evaluated immediately at class definition time.
    #
    # Calling this more than once for the same context adds to the existing
    # scope rather than replacing it, so a plugin may register for an entity
    # from several places, each with its own condition.
    #
    # @param context [String, Class] Name of the entity class to scope to.
    # @param condition [Proc] Optional condition applied before rendering the
    #   components and tabs registered in this block.
    # @yieldparam scope [EntityScope] Scope object for entity-specific
    #   registrations.
    # @return [EntityScope] The scope for the context.
    def self.for_entity(context, condition = nil, &block)
      @entities ||= {}
      scope = (@entities[context.to_s] ||= EntityScope.new(self, context.to_s))
      scope.with_condition(condition) { block.call(scope) }

      scope
    end

    # @!endgroup

    # @!group Registration

    # Registers this plugin class with the global registry.
    #
    # Registration also survives a code reload. The engine clears the registry
    # on every `to_prepare` and replays the `:junction_plugins` load hooks to
    # rebuild it.
    #
    # @raise [ArgumentError] If plugin_name is nil, does not match the valid
    #   format, or if the plugin declares permissions without a domain.
    def self.register
      unless plugin_name&.match?(PLUGIN_NAME_REGEXP)
        raise ArgumentError,
          "Plugin name #{plugin_name.inspect} is invalid. Must match the format /[a-z][a-z0-9_-]+/"
      end

      if permissions.any? { |permission| permission.domain.blank? }
        raise ArgumentError,
          "Plugin #{plugin_name.inspect} declares permissions but no domain. " \
          "Permission strings are \"<domain>/<context>.<ownership>.<access>\", " \
          "so without one they cannot be parsed or granted."
      end

      ApplicationPlugin.registrations[plugin_name] = self
      Junction::PluginRegistry.register_plugin(self)
    end

    # Re-registers every plugin that has registered in this process.
    #
    # Called from the engine's `:junction_plugins` load hook, which the engine
    # replays after clearing the registry on a code reload.
    #
    # Replay goes back through {register} rather than straight to the registry,
    # so a plugin that changed while reloading is validated and re-recorded
    # exactly as it would be on a first registration.
    #
    # A named plugin is resolved from its class name, so a plugin class in an
    # autoload path re-registers as the class that replaced it. One whose
    # constant is gone is dropped rather than revived from the stale object,
    # since a class keeps its name after its constant is removed. An anonymous
    # class has no name to resolve and is registered as itself.
    #
    # The snapshot matters: {register} writes to the registrations, and a
    # plugin renamed while reloading would add a key mid-iteration.
    def self.replay_registrations
      registrations.to_a.each do |name, plugin|
        current = plugin.name ? plugin.name.safe_constantize : plugin

        if current.is_a?(Class) && current <= ApplicationPlugin
          current.register
        else
          registrations.delete(name)
        end
      end
    end

    # Plugins that have been registered, by plugin name.
    #
    # Always reads the base class, since a subclass would otherwise see its own
    # empty hash.
    #
    # @return [Hash{String => Class<ApplicationPlugin>}] The registrations.
    def self.registrations
      ApplicationPlugin.instance_variable_get(:@registrations)
    end

    # @!endgroup

    # @!group Constant Resolution

    # Resolves a constant within this plugin's namespace.
    #
    # The namespace is inferred from the class's Ruby module hierarchy.
    #
    # @example Resolving a constant.
    #   MyPlugin::Plugin.resolve("Components::Header")
    #   # => MyPlugin::Components::Header
    #
    # @param constant [String] The constant name to resolve.
    # @return [Class, Module]
    # @raise [RuntimeError] If called on an anonymous class.
    def self.resolve(constant)
      raise "Cannot resolve constants on an anonymous plugin class" if name.nil?

      namespace_module.const_get(constant)
    end

    # @!endgroup

    # @!group Data Retrieval

    # Routable actions grouped by their context class name.
    #
    # @return [Hash<String, Array>]
    def self.actions
      (@entities || {}).transform_values(&:actions)
    end

    # Retrieves all registered annotations for a given context.
    #
    # @param context [String] Name of the entity class.
    # @return [Hash<String, Hash>]
    def self.annotations_for(context)
      (@entities || {})[context.to_s]&.annotations || {}
    end

    # Retrieves all registered UI components for a given context and slot.
    #
    # @param context [String] Name of the entity class.
    # @param slot [Symbol] The page slot to retrieve components for.
    # @return [Array<Hash>]
    def self.components_for(context, slot)
      (@entities || {})[context.to_s]&.components_for(slot) || []
    end

    # Retrieves all registered tabs for a given context.
    #
    # @param context [String] Name of the entity class.
    # @return [Array<Hash>]
    def self.tabs_for(context)
      (@entities || {})[context.to_s]&.tabs || []
    end

    # All permissions registered by this plugin.
    #
    # @return [Array<Junction::Permission>]
    def self.permissions
      (@permission_definitions || []).map do |definition|
        Junction::Permission.new(domain: self.domain, **definition)
      end
    end

    # All registered authentication providers for this plugin.
    #
    # @return [Hash<Symbol, Hash>]
    def self.auth_providers
      @auth_providers || {}
    end

    # All registered sidebar links for this plugin.
    #
    # @return [Array<Hash>]
    def self.sidebar_links
      @sidebar_links || []
    end

    # All registered settings menu items for this plugin.
    #
    # @return [Array<Hash>]
    def self.settings_menu_items
      @settings_menu_items || []
    end

    # @!endgroup

    # The namespace module for this plugin.
    #
    # @return [Module]
    private_class_method def self.namespace_module
      ns = name.deconstantize
      ns.empty? ? Object : ns.constantize
    end
  end
end
