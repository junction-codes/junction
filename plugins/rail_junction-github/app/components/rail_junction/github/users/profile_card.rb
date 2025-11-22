# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Users
        # Render a card for a user's GitHub profile.
        class ProfileCard < Base
          DEFAULT_ATTRS = { class: "h-full" }.freeze

          def view_template
            ::Components::Card(**attrs) do |card|
              ProfileCardHeader(entity:, user:)

              card.content do
                div(class: "grid grid-cols-2 gap-2 mb-4") do
                  ProfileCardStat(entity:, title: "Followers", value: user.followers)
                  ProfileCardStat(entity:, title: "Public Repos", value: user.public_repos)
                end

                div(class: "space-y-2") do
                  ProfileCardLink(entity:, user:, title: "View Repositories", icon: "bookmark", tab: "repositories")
                  ProfileCardLink(entity:, user:, title: "View Stars", icon: "star", tab: "stars")
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
