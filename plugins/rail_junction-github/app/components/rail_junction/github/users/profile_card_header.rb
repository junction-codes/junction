# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Users
        # Render the header section of a GitHub profile card.
        class ProfileCardHeader < Base
          def view_template
            ::Components::CardHeader(**attrs) do
              div(class: "flex items-center gap-4") do
                img(src: user.avatar_url, alt: username,
                    class: "h-12 w-12 rounded-full border bg-muted")

                div do
                  CardTitle { "GitHub Profile" }
                  div(class: "text-sm text-muted-foreground") do
                    Link(href: user.html_url, target: "_blank",
                         class: "hover:underline flex items-center gap-1") do
                      "@#{username}"
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
