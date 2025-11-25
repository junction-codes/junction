# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Teams
        # Render the header section of a GitHub team profile card.
        class ProfileCardHeader < Base
          def view_template
            ::Components::CardHeader(**attrs) do
              div(class: "flex items-center gap-4") do
                img(src: team.organization.avatar_url, alt: team.name,
                    class: "h-12 w-12 rounded-full border bg-muted")

                div do
                  CardTitle { "GitHub Team" }
                  div(class: "text-sm text-muted-foreground") do
                    Link(href: team.html_url, target: "_blank",
                         class: "hover:underline flex items-center gap-1") do
                      "@#{team.slug}"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
