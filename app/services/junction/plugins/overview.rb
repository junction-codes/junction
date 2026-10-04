# frozen_string_literal: true

module Junction
  module Plugins
    # Provides an overview of all installed plugins.
    #
    # A plugin declares itself through the plugin base class rather than
    # patching core, so everything it contributes can be listed by asking the
    # class what it registered.
    class Overview
      # One plugin, as the settings screen lists it.
      Summary = Struct.new(:id, :title, :description, :domain, :core,
                           :class_name, :source_path, :groups,
                           keyword_init: true)

      # Every installed plugin, with built-in ones first.
      #
      # @return [Array<Summary>] Plugin summaries.
      def plugins
        @plugins ||= PluginRegistry.plugins.values.map { |plugin| summarize(plugin) }
                                   .sort_by { |summary| [ summary.core ? 0 : 1, summary.title.to_s ] }
      end

      # Core plugins provided by the Junction engine.
      #
      # @return [Array<Summary>] Core plugins.
      def core
        plugins.select(&:core)
      end

      # Plugins installed by the host application, excluding core ones.
      #
      # @return [Array<Summary>] Installed plugins.
      def installed
        plugins.reject(&:core)
      end

      private

      # Summarizes the details of a plugin.
      #
      # @param plugin [Class<ApplicationPlugin>] The plugin class.
      # @return [Summary] Plugin summary.
      def summarize(plugin)
        Summary.new(
          id: plugin.plugin_name,
          title: plugin.title.presence || plugin.plugin_name,
          description: plugin.description,
          domain: plugin.domain,
          core: plugin == Junction::CorePlugin,
          class_name: plugin.name,
          source_path: source_path(plugin),
          groups: groups(plugin)
        )
      end

      # Grouped overview of what the plugin provides.
      #
      # Empty groups are still included to indicate the absence of their
      # contributions.
      #
      # Each group has an `:id` and an `:items` array.
      #
      # @param plugin [Class<ApplicationPlugin>] The plugin class.
      # @return [Array<Hash>] The grouped overview of the plugin's
      #   contributions.
      def groups(plugin)
        contexts = plugin.registered_contexts

        [
          { id: :sidebar_links, items: sidebar_links(plugin) },
          { id: :routes, items: routes(plugin) },
          { id: :entity_tabs, items: entity_tabs(plugin, contexts) },
          { id: :components, items: components(plugin, contexts) },
          { id: :annotation_keys, items: annotation_keys(plugin, contexts) },
          { id: :permissions, items: plugin.permissions.map(&:to_s) }
        ]
      end

      # Sidebar links provided by a plugin.
      #
      # A link registers a route helper rather than a path, since the path is
      # only knowable once the host application has mounted the engine.
      #
      # @return [Array<String>] Sidebar links, as "Title  →  helper".
      def sidebar_links(plugin)
        plugin.sidebar_links.map do |link|
          [ link[:title], link[:action] ].compact.join("  →  ")
        end
      end

      # Registered actions are routes.
      #
      # Most registered routes are used for lazy-loaded tabs rendered with a
      # catalog item, rather than a full page. It's still worth documenting
      # them for the user.
      #
      # @return [Array<String>] The paths, or the controller actions behind
      #   them.
      def routes(plugin)
        plugin.actions.values.flatten.map do |action|
          action[:path].presence ||
            "#{action[:controller]}##{action[:action]}"
        end
      end

      # Tabs provided by a plugin for a given kind.
      #
      # @return [Array<String>] Each tab, and what it sits on.
      def entity_tabs(plugin, contexts)
        contexts.flat_map do |context|
          plugin.tabs_for(context).map do |tab|
            "#{tab[:title]}  ·  #{label_for(context)}"
          end
        end
      end

      # UI components provided by a plugin for a given kind.
      #
      # @return [Array<String>] Each component, and the slot it fills.
      def components(plugin, contexts)
        contexts.flat_map do |context|
          plugin.components_for_context(context).map do |component|
            "#{component[:component]}  ·  #{component[:slot]}"
          end
        end
      end

      # Annotations defined by a plugin for a given kind.
      #
      # @return [Array<String>] The keys the plugin declares.
      def annotation_keys(plugin, contexts)
        contexts.flat_map { |context| plugin.annotations_for(context).keys }.uniq
      end

      # Source path for a plugin class.
      #
      # @param plugin [Class<ApplicationPlugin>] The plugin class.
      # @return [String, nil] A path relative to the application root.
      def source_path(plugin)
        path = plugin.name && Object.const_source_location(plugin.name)&.first
        return if path.blank?

        root = Rails.root.to_s
        path.start_with?(root) ? path.delete_prefix("#{root}/") : path
      end

      # Human-readable label for a given context.
      #
      # @param context [String] A kind name, as the plugin registered it.
      # @return [String] What that kind is called.
      def label_for(context)
        kind = Junction::Kinds.for(context.demodulize)

        kind&.model&.model_name&.human(count: 2) || context.demodulize
      end
    end
  end
end
