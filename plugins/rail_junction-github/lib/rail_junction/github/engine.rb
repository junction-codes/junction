# frozen_string_literal: true

module RailJunction
  module Github
    class Engine < ::Rails::Engine
      ANNOTATION_PROJECT_SLUG = "github.com/project-slug"
      ANNOTATION_TEAM_SLUG = "github.com/team-slug"
      ANNOTATION_USER_LOGIN = "github.com/user-login"

      HAS_PROJECT_SLUG = ->(context:) { context.annotations[ANNOTATION_PROJECT_SLUG].present? }.freeze
      HAS_TEAM_SLUG = ->(context:) { context.annotations[ANNOTATION_TEAM_SLUG].present? }.freeze
      HAS_USER_LOGIN = ->(context:) { context.annotations[ANNOTATION_USER_LOGIN].present? }.freeze

      isolate_namespace RailJunction::Github

      ActiveSupport.on_load(:junction_plugins) do
        plugin = Plugin.new("github", RailJunction::Github, icon: "github", title: "GitHub")
        plugin.auth_provider ENV["GITHUB_KEY"], ENV["GITHUB_SECRET"], callback: ->(auth) {
          User.find_by(annotations: { ANNOTATION_USER_LOGIN => auth.info.nickname })
        }

        %w[Api Component].each do |context|
          plugin.for_entity context, HAS_PROJECT_SLUG do |entity|
            name = context.to_s.downcase
            entity.annotation key: ANNOTATION_PROJECT_SLUG,
                              title: "GitHub Repository Slug",
                              placeholder: "my-org/my-repo"

            entity.action method: :"#{name}_github_actions_path",
                          controller: "rail_junction/github/actions",
                          action: "index"
            entity.tab title: "CI/CD", icon: "workflow",
                        action: :"#{name}_github_actions_path"

            entity.action method: :"#{name}_github_issues_path",
                          controller: "rail_junction/github/issues",
                          action: "index"
            entity.tab title: "Issues", icon: "bug",
                        action: :"#{name}_github_issues_path"

            entity.action method: :"#{name}_github_pull_requests_path",
                          controller: "rail_junction/github/pull_requests",
                          action: "index"
            entity.tab title: "Merge Requests", icon: "git-pull-request-arrow",
                        action: :"#{name}_github_pull_requests_path"

            entity.component slot: :overview_cards, component: "Components::OpenPrStatCard"
            entity.component slot: :overview_cards, component: "Components::OpenIssuesStatCard"
          end
        end

        plugin.for_entity "Group", HAS_TEAM_SLUG do |entity|
          entity.annotation key: ANNOTATION_TEAM_SLUG,
                            title: "GitHub Team Slug",
                            placeholder: "my-org/my-team"

          entity.action method: :"group_github_pull_requests_path",
                        controller: "rail_junction/github/pull_requests",
                        action: "index"
          entity.tab title: "Merge Requests", icon: "git-pull-request-arrow",
                      action: :"group_github_pull_requests_path"

          entity.component slot: :group_profile_cards, component: "Components::Teams::ProfileCard"
        end

        plugin.for_entity "User", HAS_USER_LOGIN do |entity|
          entity.annotation key: ANNOTATION_USER_LOGIN,
                            title: "GitHub Username",
                            placeholder: "benderbendingrodriguez"

          entity.component slot: :user_profile_cards, component: "Components::Users::ProfileCard"
        end

        plugin.register
      end
    end
  end
end
