# frozen_string_literal: true


module RailJunction
  module Github
    class Engine < ::Rails::Engine
      isolate_namespace RailJunction::Github

      config.after_initialize do
        # TODO: Remove unless we need a sidebar link for this plugin.
        PluginRegistry.instance.register_sidebar_link(
          title: "GitHub Stats",
          path: :components_path,
          icon: "github",
          disabled: true
        )

        PluginRegistry.instance.register_routable_plugin_action(
          context_class: ::Component,
          path_method: :component_github_actions_path,
          controller: "rail_junction/github/actions",
          action: "index"
        )

        PluginRegistry.instance.register_routable_plugin_action(
          context_class: ::Component,
          path_method: :component_github_pull_requests_path,
          controller: "rail_junction/github/pull_requests",
          action: "index"
        )

        # TODO: We shouldn't have to do this.
        require_relative "../../../app/components/actions_tab"
        require_relative "../../../app/components/pull_requests_tab"
        require_relative "../../../app/components/open_issues_stat_card"
        require_relative "../../../app/components/open_pr_stat_card"

        PluginRegistry.instance.register_stat_card(
          context_class: ::Component,
          component: RailJunction::Github::Components::OpenPrStatCard
        )

        PluginRegistry.instance.register_stat_card(
          context_class: ::Component,
          component: RailJunction::Github::Components::OpenIssuesStatCard
        )

        PluginRegistry.instance.register_tab(
          context_class: ::Component,
          title: "CI/CD",
          icon: "workflow",
          path_method: :component_github_actions_path,
        )

        PluginRegistry.instance.register_tab(
          context_class: ::Component,
          title: "Pull Requests",
          icon: "git-pull-request-arrow",
          path_method: :component_github_pull_requests_path,
        )
      end
    end
  end
end
