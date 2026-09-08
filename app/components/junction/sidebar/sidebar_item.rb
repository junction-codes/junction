# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      class SidebarItem < Base
        # Initializes a new component.
        #
        # @param icon [String] Icon for the row.
        # @param title [String] Label for the row.
        # @param count [Integer, nil] How many entities the row leads to. Nil
        #   means the row does not carry a count, which is not the same as zero.
        # @param disabled [Boolean] Whether the row is inert.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(icon:, title:, count: nil, disabled: false, **user_attrs)
          @icon = icon
          @title = title
          @count = count
          @disabled = disabled

          super(**user_attrs)
        end

        def view_template
          div do
            render Link.new(variant: @disabled ? :disabled : :link, **attrs) do
              span(class: "flex-shrink-0") do
                icon(@icon, fallback: Junction::Kind::DEFAULT_ICON,
                     class: "w-6 h-6")
              end
              span(data_sidebar_target: "linkText", class: "ml-4 whitespace-nowrap") { @title }
              count_badge
            end
          end
        end

        private

        # Renders the count, when the row has one.
        def count_badge
          return if @count.nil?

          span(data_sidebar_target: "linkText",
               class: "ml-auto text-xs tabular-nums text-muted-foreground") do
            @count.to_s
          end
        end
      end
    end
  end
end
