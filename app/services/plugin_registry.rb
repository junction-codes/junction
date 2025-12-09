# frozen_string_literal: true

require "singleton"

# Registry for managing plugin hooks into the application.
class PluginRegistry
  include Singleton

  class PluginNotFoundError < ArgumentError; end

  class << self
    # Delegate class methods to the singleton instance.
    delegate :actions, :annotations_for, :auth_providers, :components_for,
             :plugin, :register_plugin, :sidebar_links, :tabs_for,
             to: :instance
  end

  # Initialize the registry.
  def initialize
    @plugins = {}
  end

  # Register a new plugin.
  #
  # @param plugin [Plugin] The plugin to register.
  def register_plugin(plugin)
    @plugins[plugin.name] = plugin
  end

  # Routable actions grouped by their context class.
  #
  # @return [Hash<String, Array>] A hash mapping context class names to arrays of action
  #   definitions.
  def actions
    actions = Hash.new { |h, k| h[k] = [] }
    @plugins.each_value do |plugin|
      plugin.actions.each do |context, definitions|
        actions[context.constantize] += definitions
      end
    end

    actions
  end

  # Retrieves all registered annotations for a given context.
  #
  # @param context [ApplicationRecord, Class, String] The model to retrieve
  #   annotations for.
  # @return [Hash<String, Hash>] A hash of annotation definitions.
  def annotations_for(context)
    @plugins.each_value.with_object({}) do |plugin, annotations|
      annotations.merge!(plugin.annotations_for(context_string(context)))
    end
  end

  # Retrieves all registered authentication providers.
  #
  # @return [Hash<String, Hash>] A hash mapping provider names to their
  #   configuration.
  def auth_providers
    @plugins.each_value.with_object({}) do |plugin, providers|
      providers.merge!(plugin.auth_providers)
    end
  end

  # Retrieves all registered UI components for a given context and slot.
  #
  # @param context [ApplicationRecord, Class, String] The model to retrieve
  #   components for.
  # @param slot [Symbol] The slot on the page to retrieve components for.
  # @return [Array<Hash>] An array of component definitions.
  def components_for(context:, slot:)
    @plugins.flat_map do |_, plugin|
      plugin.components_for(context_string(context), slot)
    end
  end

  # Retrieves a registered plugin by name.
  #
  # @param name [String] The name of the plugin.
  # @return [Plugin] The plugin instance.
  #
  # @raise [PluginNotFoundError] If the plugin is not found.
  def plugin(name)
    raise PluginNotFoundError, "Plugin not found: #{name}" unless @plugins.key?(name)

    @plugins[name]
  end

  # Retrieves all registered sidebar links.
  #
  # @return [Array<Hash>] An array of sidebar link definitions.
  def sidebar_links
    @plugins.flat_map(&:sidebar_links)
  end

  # Retrieves all registered tabs for a given context.
  #
  # @param context [Class, ApplicationRecord] The model to retrieve tabs for.
  # @return [Array<Hash>] An array of tab definitions.
  def tabs_for(context)
    @plugins.flat_map { |plugin| plugin.tabs_for(context_string(context)) }
  end

  private

  # Converts a context object or class into its string representation.
  #
  # @param context [ApplicationRecord, Class, String] The context to get the
  #   class of.
  # @return [String] The context as a string.
  def context_string(context)
    return context if context.is_a?(String)

    context.is_a?(Class) ? context.to_s : context.class.to_s
  end
end
