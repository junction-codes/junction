# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Teams
        # Render a link for a team's profile card.
        class ProfileCardLink < Base
          DEFAULT_ATTRS = { variant: :outline, target: "_blank", class: "w-full justify-start" }.freeze

          # Initialize a new component.
          #
          # @param title [String] The title of the link.
          # @param icon [Symbol] The icon to display alongside the title.
          # @param path [String,] Optional profile subpath to add to the URL.
          # @param user_attrs [Hash] Additional attributes for the component.
          def initialize(title:, icon:, path: nil, **user_attrs)
            @title = title
            @icon = icon
            @path = path
            super(**user_attrs)
          end

          def view_template
            ::Components::Link(**attrs) do
              icon(@icon, class: "mr-2 h-4 w-4")
              plain @title
            end
          end

          private

          def default_attrs
            DEFAULT_ATTRS.merge(href:)
          end

          # URL to the team's profile or specific page.
          #
          # @return [String] The constructed URL.
          def href
            return team.html_url unless @path.present?

            "#{team.html_url}/#{@path}"
          end
        end
      end
    end
  end
end
