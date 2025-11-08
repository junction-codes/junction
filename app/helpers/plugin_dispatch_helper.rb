# frozen_string_literal: true

module PluginDispatchHelper
  # Renders all registered sidebar links.
  def render_sidebar_links(sidebar)
    PluginRegistry.instance.sidebar_links.each do |link|
      params = link
      params[:href] = params[:path].is_a?(Symbol) ? main_app.send(params.delete(:path)) : params.delete(:path)
      sidebar.item(**params)
    end
  end

  # Renders the <Tabs::Trigger> components for a given object (e.g., a System).
  def render_plugin_tab_triggers(context_object, tabs_list)
    PluginRegistry.instance.tabs_for(context_object).each do |tab|
      tabs_list.trigger(value: tab[:title].parameterize) do
        icon(tab[:icon], class: "pe-2") if tab[:icon].present?
        plain tab[:title]
      end
    end
  end

  # Renders the <Tabs::Content> components for a given object.
  def render_plugin_tab_content(context_object, tabs_component)
    PluginRegistry.instance.tabs_for(context_object).each do |tab|
      tabs_component.content(value: tab[:title].parameterize) do
        h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { tab[:title] }

        if tab[:path_method].present?
          turbo_frame_tag(tab[:target], src: main_app.send(tab[:path_method], context_object), loading: :lazy) do
            div(class: "p-4") { render Components::Skeleton(class: "h-20") }
          end
        elsif tab[:component].present?
          render tab[:component].new(object: context_object)
        end
      end
    end
  end

  # Renders all registered stat cards for a given object.
  def render_plugin_stat_cards(context_object)
    cards = PluginRegistry.instance.cards_for(context_object, type: :stat)
    cards.each do |card|
      # Each plugin registers its own Phlex component class to be rendered.
      render card[:component].new(object: context_object)
    end
  end
end
