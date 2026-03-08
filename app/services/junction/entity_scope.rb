# frozen_string_literal: true

module Junction
  # Plugin registration scope for a specific entity context.
  class EntityScope
    attr_reader :actions, :annotations, :plugin, :tabs

    # Initializes a new entity scope.
    #
    # @param plugin [Plugin] The parent plugin.
    # @param context [String] Name of the entity class to scope registrations to.
    # @param condition [Proc] Optional condition to be applied to supported
    #   registrations.
    def initialize(plugin, context, condition = nil)
      @plugin = plugin
      @context = context
      @condition = condition

      @annotations = Hash.new { |h, k| h[k] = [] }
      @actions = []
      @tabs = []
      @components = Hash.new { |h, k| h[k] = [] }
    end

    # Registers a routable action for the entity.
    #
    # @param method [Symbol] Rails route helper method for the action..
    # @param controller [String] The controller handling the action.
    # @param action [Symbol] The specific action within the controller.
    # @param path [String] Optional custom path for the action.
    def action(method:, controller:, action: :index, path: nil)
      @actions << { method:, controller:, path:, action: }
    end

    # Registers an annotation for the entity.
    #
    # @param key [String] The unique key for the annotation.
    # @param title [String] The human-readable title for the annotation.
    # @param placeholder [String] Optional placeholder text for the annotation.
    def annotation(key:, title:, placeholder: nil)
      @annotations[key] = { key:, title:, placeholder: }
    end

    # Registers a UI component for the entity.
    #
    # @param slot [Symbol] The slot on the page to render the component in.
    # @param component [String] The component class name as a string.
    def component(slot:, component:)
      @components[slot] << { slot:, component:, if: @condition }
    end

    # Registers a tab for the entity.
    #
    # Access control can be specified in two ways:
    # - A symbol is evaluated against the entity's implicit policy
    # - A hash of `{ action:, with: }` specifies a custom policy class; `with:`
    #   may be a class or a string that is resolved at render time
    #
    # @example Registering a tab with an implicit policy:
    #   plugin.for_entity("Junction::Domain") do |s|
    #     s.tab(title: "Details", action: :domain_path, access: :show?)
    #   end
    #
    # @example Registering a tab with a custom policy class:
    #   plugin.for_entity("Junction::Domain") do |s|
    #     s.tab(
    #       title: "Details",
    #       action: :domain_path,
    #       access: { action: :manage?, with: "MyPlugin::DomainPolicy" }
    #     )
    #   end
    #
    # @param title [String] Title of the tab.
    # @param action [Symbol] Rails route helper method for the tab.
    # @param icon [String] Optional icon for the tab.
    # @param target [String] Optional target identifier for the turbo frame
    #   within the tab.
    # @param access [Symbol, Hash] Optional access check.
    def tab(title:, action:, icon: nil, target: nil, access: nil)
      target ||= action&.to_s&.gsub("_path", "")&.gsub("_", "-") || title.parameterize
      @tabs << { title:, action:, icon:, if: @condition, target:, access:, plugin: }
    end

    # Retrieves all registered UI components for the given slot.
    #
    # @param slot [Symbol] The slot on the page to retrieve components for.
    # @return [Array<Hash>] An array of component definitions.
    def components_for(slot)
      return [] unless @components.key?(slot)

      @components[slot].map do |component|
        component[:component] = @plugin.resolve(component[:component]) if component[:component].is_a?(String)
        component
      end
    end
  end
end
