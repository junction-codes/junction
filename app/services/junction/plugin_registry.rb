# frozen_string_literal: true

require "monitor"
require "set"
require "singleton"

require_relative "../../helpers/junction/instrumentation_helper"

module Junction
  # Registry for managing plugin hooks into the application.
  class PluginRegistry
    include InstrumentationHelper
    include Singleton

    class PluginNotFoundError < ArgumentError; end

    attr_reader :plugins

    class << self
      # Delegate class methods to the singleton instance.
      delegate :actions, :annotations_for, :auth_providers, :components_for,
               :permissions, :plugin, :plugin_route_helper_entity_classes,
               :plugins, :register_plugin, :reset!, :resolve,
               :settings_menu_items, :sidebar_links, :tabs_for,
               to: :instance
    end

    # Initialize the registry.
    #
    # We use a monitor rather than a mutex because {memoize} yields while
    # holding the lock, so a memoized value computed from another memoized value
    # would deadlock on a lock that is not reentrant.
    def initialize
      @cache = {}
      @monitor = Monitor.new
      @plugins = {}
    end

    # Register a new plugin.
    #
    # @param plugin [Class<ApplicationPlugin>] The plugin to register.
    def register_plugin(plugin)
      trace "junction.plugin.register", "junction.plugin.name" => plugin.plugin_name do
        @monitor.synchronize do
          @plugins[plugin.plugin_name] = plugin
          @cache = {}
        end
      end
    end

    # Reset the registry, clearing all registered plugins and the cache.
    def reset!
      @monitor.synchronize do
        @plugins = {}
        @cache = {}
      end
    end

    # Routable actions grouped by their context class.
    #
    # @return [Hash<Class, Array>] A hash mapping context classes to arrays of
    #   action definitions.
    def actions
      trace "junction.registry.actions" do
        memoize(:actions) do
          result = Hash.new { |h, k| h[k] = [] }
          @plugins.each_value do |plugin|
            plugin.actions.each do |context, definitions|
              result[context.constantize] += definitions
            rescue NameError
              Rails.logger.error \
                "Plugin \"#{plugin.plugin_name}\" registered actions for unknown context: #{context}"
              next
            end
          end

          result
        end
      end
    end

    # Retrieves all registered annotations for a given context.
    #
    # @param context [ApplicationRecord, Class, String] The model to retrieve
    #   annotations for.
    # @return [Hash<String, Hash>] A hash of annotation definitions.
    def annotations_for(context)
      ctx = context_string(context)
      trace "junction.registry.annotations_for", "junction.plugin.context" => ctx do
        memoize([ :annotations_for, ctx ]) do
          inherited_contexts(ctx).each_with_object({}) do |name, annotations|
            @plugins.each_value do |plugin|
              annotations.merge!(plugin.annotations_for(name))
            end
          end
        end
      end
    end

    # Retrieves all registered authentication providers.
    #
    # @return [Hash<Symbol, Hash>] A hash mapping provider names to their
    #   configuration.
    def auth_providers
      trace "junction.registry.auth_providers" do
        memoize(:auth_providers) do
          @plugins.each_value.with_object({}) do |plugin, providers|
            providers.merge!(plugin.auth_providers)
          end
        end
      end
    end

    # Retrieves all registered UI components for a given context and slot.
    #
    # @param context [ApplicationRecord, Class, String] The model to retrieve
    #   components for.
    # @param slot [Symbol] The slot on the page to retrieve components for.
    # @return [Array<Hash>] An array of component definitions.
    def components_for(context:, slot:)
      ctx = context_string(context)
      trace "junction.registry.components_for",
            "junction.plugin.context" => ctx,
            "junction.plugin.slot" => slot.to_s do
        memoize([ :components_for, ctx, slot ]) do
          inherited_contexts(ctx).flat_map do |name|
            @plugins.flat_map { |_, plugin| plugin.components_for(name, slot) }
          end
        end
      end
    end

    # Retrieves a registered plugin by name.
    #
    # @param name [String] The plugin name.
    # @return [Class<ApplicationPlugin>] The plugin class.
    #
    # @raise [PluginNotFoundError] If the plugin is not found.
    def plugin(name)
      return @plugins[name] if @plugins.key?(name)

      raise PluginNotFoundError, "Plugin not found: #{name}"
    end

    # All permissions from all registered plugins.
    #
    # @return [Array<Junction::Permission>]
    def permissions
      trace "junction.registry.permissions" do
        memoize(:permissions) do
          seen = Set.new
          @plugins.values.flat_map(&:permissions).select { |p| seen.add?(p.to_s) }
        end
      end
    end

    # Resolves a constant from a specific plugin's namespace.
    #
    # @param plugin_name [String] The name of the plugin.
    # @param constant [String] The constant name to resolve.
    # @return [Class, Module]
    def resolve(plugin_name, constant)
      trace "junction.plugin.resolve",
            "junction.plugin.name" => plugin_name.to_s,
            "junction.plugin.constant" => constant.to_s do
        plugin(plugin_name).resolve(constant)
      end
    end

    # Retrieves all registered sidebar links.
    #
    # @return [Array<Hash>] An array of sidebar link definitions.
    def sidebar_links
      trace "junction.registry.sidebar_links" do
        memoize(:sidebar_links) do
          @plugins.values.flat_map(&:sidebar_links)
        end
      end
    end

    # Retrieves all registered sidebar settings menu items.
    #
    # @return [Array<Hash>] An array of settings menu item definitions.
    def settings_menu_items
      trace "junction.registry.settings_menu_items" do
        memoize(:settings_menu_items) do
          @plugins.values.flat_map(&:settings_menu_items)
        end
      end
    end

    # Retrieves all registered tabs for a given context.
    #
    # @param context [Class, ApplicationRecord] The model to retrieve tabs for.
    # @return [Array<Hash>] An array of tab definitions.
    def tabs_for(context)
      ctx = context_string(context)
      trace "junction.registry.tabs_for", "junction.plugin.context" => ctx do
        memoize([ :tabs_for, ctx ]) do
          inherited_contexts(ctx).flat_map do |name|
            @plugins.values.flat_map { |plugin| plugin.tabs_for(name) }
          end
        end
      end
    end

    # Maps plugin route helper symbols to the model classes they're mounted
    # under.
    #
    # @return [Hash{Symbol => Class}]
    def plugin_route_helper_entity_classes
      memoize(:plugin_route_helper_entity_classes) do
        {}.tap do |map|
          @plugins.each_value do |plugin|
            plugin.actions.each do |context, definitions|
              context_class = context.constantize
              definitions.each { |definition| map[definition[:method]] = context_class }
            rescue NameError
              Rails.logger.error \
                "Plugin \"#{plugin.plugin_name}\" registered actions for unknown context: #{context}"
            end
          end
        end
      end
    end

    private

    # Memoizes a result by key, thread-safely.
    #
    # @param key [Symbol] The key to memoize the result by.
    # @return [Object] The memoized result.
    def memoize(key)
      @monitor.synchronize do
        if @cache.key?(key)
          span_attribute("junction.registry.cache_hit", true)
          return @cache[key]
        end

        span_attribute("junction.registry.cache_hit", false)
        @cache[key] = yield
      end
    end

    # Class names to use when looking up entity-scoped registrations.
    #
    # Every kind shares one base class, and subclassing a core kind is how a
    # plugin adds one, so a registration for `Junction::Component` has to
    # answer for a plugin kind that subclasses it. Least specific first means a
    # registration on the subclass wins when the two collide.
    #
    # A context that is not an entity resolves to itself alone.
    #
    # @param name [String] Name of the context class.
    # @return [Array<String>] The class names, ordered least specific to most
    #   specific.
    def inherited_contexts(name)
      klass = name.safe_constantize
      return [ name ] unless klass.is_a?(Class) && klass <= Junction::Entity

      klass.ancestors
           .select { |ancestor| ancestor.is_a?(Class) && ancestor <= Junction::Entity }
           .map(&:to_s)
           .reverse
    end

    # Converts a context object or class into its string representation.
    #
    # @param context [ApplicationRecord, Class, String] The context to convert.
    # @return [String]
    def context_string(context)
      return context if context.is_a?(String)

      context.is_a?(Class) ? context.to_s : context.class.to_s
    end
  end
end
