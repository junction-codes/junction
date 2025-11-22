# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Users
        # Render a link for a user's profile card.
        class ProfileCardLink < Base
          DEFAULT_ATTRS = { variant: :outline, target: "_blank", class: "w-full justify-start" }.freeze

          # Initialize a new component.
          #
          # @param title [String] The title of the link.
          # @param icon [Symbol] The icon to display alongside the title.
          # @param tab [String,] Optional profile tab to append to the URL.
          # @param user_attrs [Hash] Additional attributes for the component.
          def initialize(title:, icon:, tab: nil, **user_attrs)
            @title = title
            @icon = icon
            @tab = tab
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

          # URL to the user's profile or specific tab.
          #
          # @return [String] The constructed URL.
          def href
            return user.html_url unless @tab

            "#{user.html_url}?tab=#{@tab}"
          end
        end
      end
    end
  end
end
