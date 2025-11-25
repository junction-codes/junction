# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Teams
        # Render a card for a group's GitHub team profile.
        class ProfileCard < Base
          DEFAULT_ATTRS = { class: "h-full" }.freeze

          def view_template
            ::Components::Card(**attrs) do |card|
              ProfileCardHeader(entity:, team:)

              card.content do
                div(class: "grid grid-cols-2 gap-2 mb-4") do
                  ProfileCardStat(entity:, title: "Members", value: team.members_count)
                  ProfileCardStat(entity:, title: "Public Repos", value: team.repos_count)
                end

                div(class: "space-y-2") do
                  ProfileCardLink(entity:, team:, title: "View Members", icon: "users", path: "members")
                  ProfileCardLink(entity:, team:, title: "View Team Repos", icon: "bookmark", path: "repositories")
                end
              end
            end
          end

          private

          def default_attrs
            { class: "h-full" }
          end
        end
      end
    end
  end
end
