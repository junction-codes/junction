# frozen_string_literal: true

require "singleton"

class PluginRegistry
  include Singleton

  # Initialize the data structures to hold our plugin registrations.
  #
  # The structure is a nested hash:
  # { hook_type => { context_class => [registration_details, ...] } }
  #
  # e.g., { tabs: { "System" => [{ title: "CI/CD", ... }] } }
  def initialize
    @hooks = {
      sidebar_links: [],
      tabs: Hash.new { |h, k| h[k] = [] },
      cards: Hash.new { |h, k| h[k] = [] }
    }
    @routable_actions = []
  end

  def register_sidebar_link(title:, path:, icon:, disabled: false)
    @hooks[:sidebar_links] << { title:, path:, icon:, disabled: }
  end

  def register_tab(context_class:, title:, component: nil, path_method: nil, icon: nil, target: nil)
    @hooks[:tabs][context_class.to_s] << {
      title:,
      path_method:,
      component:,
      icon:,
      target: target || path_method&.to_s&.gsub("_path", "") || title.parameterize
    }
  end

  def register_stat_card(context_class:, component:)
    @hooks[:cards][context_class.to_s] << { type: :stat, component: }
  end

  def register_routable_plugin_action(context_class:, path_method:, controller:, path: nil, action: :index)
    @routable_actions << {
      context_class: context_class.to_s,
      path_method:,
      controller:,
      action:,
      path:
    }
  end

  def sidebar_links
    @hooks[:sidebar_links]
  end

  def tabs_for(context_object)
    @hooks[:tabs][context_object.class.to_s]
  end

  def cards_for(context_object, type:)
    @hooks[:cards][context_object.class.to_s].select { |card| card[:type] == type }
  end

  def routable_actions_grouped_by_context
    @routable_actions.group_by { |action| action[:context_class] }
  end
end
