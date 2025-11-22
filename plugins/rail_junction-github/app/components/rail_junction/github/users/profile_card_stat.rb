# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Users
        # Display a single statistic for a GitHub user profile card.
        class ProfileCardStat < Base
          DEFAULT_ATTRS = { class: "p-3 bg-muted/50 rounded-lg text-center" }.freeze

          # Initialize a new component.
          #
          # @param title [String] The title of the statistic.
          # @param value [String, Integer] The value of the statistic.
          # @param user_attrs [Hash] Additional attributes for the component.
          def initialize(title:, value:, **user_attrs)
            @title = title
            @value = value
            super(**user_attrs)
          end

          def view_template
            div(**attrs) do
              div(class: "text-2xl font-bold") { @value }
              div(class: "text-xs text-muted-foreground uppercase tracking-wide") { @title }
            end
          end
        end
      end
    end
  end
end
