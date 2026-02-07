# frozen_string_literal: true

module Junction
  # Helper methods for rendering plugin-dispatched UI components.
  module PluginDispatchHelper
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

    # Retrieves the tabes that are visible for the given context.
    #
    # @param context [ApplicationRecord] The record to check visibility against.
    # @return [Array<Hash>] Definitions for the visible tabs.
    def visible_tabs(context)
      Junction::PluginRegistry.tabs_for(context).select do |tab|
        tab[:if].nil? || tab[:if].call(context:)
      end
    end

    # Resolves a plugin route helper within the engine or host app.
    #
    # @param action [Symbol] The route helper method to call.
    # @param args [Array] Arguments to pass to the route helper.
    # @return [String] The resolved URL or path.
    #
    # @raise [ArgumentError] If the route helper cannot be found.
    def resolve_plugin_route(action, *args)
      if respond_to?(action)
        return public_send(action, *args)
      elsif respond_to?(:main_app) && main_app.respond_to?(action)
        return main_app.public_send(action, *args)
      elsif Junction::Engine.routes.url_helpers.respond_to?(action)
        return Junction::Engine.routes.url_helpers.public_send(action, *args)
      end

      raise ArgumentError, "Unknown plugin route helper: #{action}"
    end
  end
end
