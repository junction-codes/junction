# frozen_string_literal: true

module RailJunction
  module Github
    class Engine < ::Rails::Engine
      ANNOTATION_PROJECT_SLUG = "github.com/project-slug"

      isolate_namespace RailJunction::Github

      config.after_initialize do
        Plugin.register "github" do |plugin|
          plugin.for_entity ::Component do |entity|
            entity.annotation key: ANNOTATION_PROJECT_SLUG,
                              title: "GitHub Repository Slug",
                              placeholder: "my-org/my-repo"

            entity.action method: :component_github_actions_path,
                          controller: "rail_junction/github/actions",
                          action: "index"
            entity.tab title: "CI/CD", icon: "workflow",
                       action: :component_github_actions_path,
                       if: ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }

            entity.action method: :component_github_issues_path,
                          controller: "rail_junction/github/issues",
                          action: "index"
            entity.tab title: "Issues", icon: "bug",
                       action: :component_github_issues_path,
                       if: ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }

            entity.action method: :component_github_pull_requests_path,
                          controller: "rail_junction/github/pull_requests",
                          action: "index"
            entity.tab title: "Merge Requests", icon: "git-pull-request-arrow",
                       action: :component_github_pull_requests_path,
                       if: ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }

            entity.component slot: :overview_cards, component: Components::OpenPrStatCard
            entity.component slot: :overview_cards, component: Components::OpenIssuesStatCard
          end
        end
      end
    end
  end
end
