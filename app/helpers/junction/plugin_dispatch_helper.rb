# frozen_string_literal: true

module Junction
  # Helper methods for rendering plugin-dispatched UI components.
  module PluginDispatchHelper
    # Returns all registered settings menu items from plugins.
    #
    # @return [Array<Hash>] Resolved settings menu item hashes.
    def plugin_settings_menu_items
      Junction::PluginRegistry.settings_menu_items.filter_map do |item|
        next unless settings_item_accessible?(item)

        item.merge(
          href: resolve_plugin_action(item[:action]),
          title: resolve_title(item)
        )
      end
    end

    # Renders all registered sidebar links.
    #
    # @param sidebar [SidebarComponent] The sidebar component to render links
    #   into.
    def render_sidebar_links(sidebar)
      Junction::PluginRegistry.instance.sidebar_links.each do |link|
        params = link
        params[:href] = params[:path].is_a?(Symbol) ? main_app.send(params.delete(:path)) : params.delete(:path)
        sidebar.item(**params)
      end
    end

    # Renders the trigger components for tabs of a given context.
    #
    # @param context [ApplicationRecord] The entity to render tabs for.
    # @param tabs_list [Tabs::List] The tab trigger list component to add the
    #   triggers to.
    def render_plugin_tab_triggers(context, tabs_list)
      visible_tabs(context).each do |tab|
        tabs_list.trigger(value: tab[:title].parameterize) do
          icon(tab[:icon], class: "pe-2") if tab[:icon].present?
          plain tab[:title]
        end
      end
    end

    # Renders the content components for tabs of a given context.
    #
    # @param context [ApplicationRecord] The entity to render tabs for.
    # @param tabs_component [Tabs::Component] The tab content component to add
    #   the contents to.
    def render_plugin_tab_content(context, tabs_component)
      visible_tabs(context).each do |tab|
        tabs_component.content(value: tab[:title].parameterize) do
          h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { tab[:title] }

          turbo_frame_tag(tab[:target], src: resolve_plugin_route(tab[:action], context), loading: :lazy) do
            div(class: "p-4") { render Components::Skeleton(class: "h-20") }
          end
        end
      end
    end

    # Renders UI components registered for a specific context and slot.
    #
    # @param context [ApplicationRecord] The record to render components for.
    # @param slot [Symbol] The slot to render components for
    def render_plugin_ui_components(context:, slot:)
      visible_components(context, slot).each do |component|
        render component[:component].new(entity: context)
      end
    end

    private

    # Resolves a plugin action to a URL or path.
    #
    # @param action [Symbol, String] The action to resolve.
    # @return [String] The resolved URL or path.
    def resolve_plugin_action(action)
      return action if action.is_a?(String) && action.start_with?("/")

      resolve_plugin_route(action)
    end

    # Determines if a settings menu item is accessible to the current user.
    #
    # @param item [Hash] The settings menu item to check access for.
    # @return [Boolean] Whether the item is accessible.
    def settings_item_accessible?(item)
      access = item[:access]
      return true unless access

      with = access[:with]
      args = with ? { with: } : {}
      allowed_to?(access[:action], access[:record], **args)
    end

    # Resolves the title for an item that supports i18n.
    #
    # @param item [Hash] Item to resolve the title for.
    # @return [String] The resolved title.
    def resolve_title(item)
      return item[:title] unless item[:title_i18n].present?

      I18n.t(item[:title_i18n], default: item[:title])
    end

    # Retrieves the UI components that are visible for the given context and
    # slot.
    #
    # @param context [ApplicationRecord] The record to check visibility against.
    # @param slot [Symbol] The slot to check components for.
    # @return [Array<Hash>] Definitions for the visible UI components.
    def visible_components(context, slot)
      Junction::PluginRegistry.components_for(context:, slot:).select do |component|
        component[:if].nil? || component[:if].call(context:)
      end
    end

    # Retrieves the tabs that are visible for the given context.
    #
    # @param context [ApplicationRecord] The record to check visibility against.
    # @return [Array<Hash>] Definitions for the visible tabs.
    def visible_tabs(context)
      Junction::PluginRegistry.tabs_for(context).select do |tab|
        next false unless tab_accessible?(tab[:access], context, tab[:plugin])

        tab[:if].nil? || tab[:if].call(context:)
      end
    end

    # Checks whether a tab's access requirement is satisfied for the context.
    #
    # @param access [Symbol, Hash, nil] Access to test, if any. Use a symbol to
    #   test against the entity's implicit policy. Use a hash to test against a
    #   custom policy class.
    # @param context [ApplicationRecord] The record to test access against.
    # @param plugin [Class<ApplicationPlugin>] The plugin the tab belongs to.
    def tab_accessible?(access, context, plugin)
      return true unless access

      if access.is_a?(Hash)
        policy = access[:with]
        policy = plugin.resolve(policy) if policy.is_a?(String)
        allowed_to?(access[:action], context, with: policy)
      else
        allowed_to?(access, context)
      end
    end

    # Resolves a plugin route helper within the engine or host app.
    #
    # @param action [Symbol] The route helper method to call.
    # @param args [Array] Arguments to pass to the route helper.
    # @return [String] The resolved URL or path.
    #
    # @raise [ArgumentError] If the route helper cannot be found.
    def resolve_plugin_route(action, *args, **kwargs)
      # If we have keyword arguments for a record, we need to remove them from
      # the positional arguments and use the keyword arguments instead.
      route_kwargs = plugin_route_kwargs(action, args, kwargs)
      if route_kwargs
        args = []
        kwargs = route_kwargs
      end

      if respond_to?(action)
        public_send(action, *args, **kwargs)
      elsif respond_to?(:main_app) && main_app.respond_to?(action)
        main_app.public_send(action, *args, **kwargs)
      elsif Junction::Engine.routes.url_helpers.respond_to?(action)
        Junction::Engine.routes.url_helpers.public_send(action, *args, **kwargs)
      else
        raise ArgumentError, "Unknown plugin route helper: #{action}"
      end
    end

    # Builds keyword arguments for a plugin route helper.
    #
    # If the first argument is a record of the class that the route helper is
    # mounted under, we build keyword arguments for the namespace and name of
    # the record. Otherwise, we assume the helper accepts the current call
    # signature and return +nil+.
    #
    # @param action [Symbol] The route helper method to call.
    # @param args [Array] Positional arguments to pass to the route helper.
    # @param kwargs [Hash] Keyword arguments to pass to the route helper.
    # @return [Hash, nil] Keyword arguments to pass to the route helper, if any.
    def plugin_route_kwargs(action, args, kwargs)
      return nil unless args.size == 1

      entity_class = Junction::PluginRegistry.plugin_route_helper_entity_classes[action]
      record = args.first
      return nil unless entity_class && record.is_a?(entity_class)

      Junction::PathHelperOverrides.namespace_name_kwargs(record).merge(kwargs)
    end
  end
end
