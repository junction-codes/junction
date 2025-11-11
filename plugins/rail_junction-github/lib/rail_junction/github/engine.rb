# frozen_string_literal: true

module RailJunction
  module Github
    class Engine < ::Rails::Engine
      ANNOTATION_PROJECT_SLUG = "github.com/project-slug"

      isolate_namespace RailJunction::Github

      config.after_initialize do
        PluginRegistry.register_annotation(
          context: ::Component,
          key: ANNOTATION_PROJECT_SLUG,
          title: "GitHub Repository Slug",
          placeholder: "my-org/my-repo"
        )

        PluginRegistry.register_action(
          context: ::Component,
          method: :component_github_actions_path,
          controller: "rail_junction/github/actions",
          action: "index"
        )

        PluginRegistry.register_action(
          context: ::Component,
          method: :component_github_pull_requests_path,
          controller: "rail_junction/github/pull_requests",
          action: "index"
        )

        # TODO: We shouldn't have to do this.
        require_relative "../../../app/components/actions_tab"
        require_relative "../../../app/components/pull_requests_tab"
        require_relative "../../../app/components/open_issues_stat_card"
        require_relative "../../../app/components/open_pr_stat_card"

        PluginRegistry.register_ui_component(
          context_class: ::Component,
          slot: :overview_cards,
          component: RailJunction::Github::Components::OpenPrStatCard
        )

        PluginRegistry.register_ui_component(
          context_class: ::Component,
          slot: :overview_cards,
          component: RailJunction::Github::Components::OpenIssuesStatCard
        )

        PluginRegistry.register_tab(
          context: ::Component,
          title: "CI/CD",
          icon: "workflow",
          action: :component_github_actions_path,
          if: ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }
        )

        PluginRegistry.register_tab(
          context: ::Component,
          title: "Pull Requests",
          icon: "git-pull-request-arrow",
          action: :component_github_pull_requests_path,
          if: ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }
        )
      end
    end
  end
end
