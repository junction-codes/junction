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
        # @param badge [String] Short word shown where a count would go, for
        #   rows that lead nowhere yet.
        # @param current [Boolean] Whether the row is the page being viewed.
        # @param disabled [Boolean] Whether the row is inert.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(icon:, title:, count: nil, badge: nil, current: false,
                       disabled: false, **user_attrs)
          @icon = icon
          @title = title
          @count = count
          @badge = badge
          @current = current
          @disabled = disabled

          super(**user_attrs)
        end

        def view_template
          render Link.new(variant: link_variant, **attrs) do
            span(class: "shrink-0 w-[18px] flex justify-center") do
              icon(@icon, fallback: Junction::Kind::DEFAULT_ICON,
                   class: "w-[18px] h-[18px]")
            end
            span(data_sidebar_target: "linkText", data_sidebar_label: "",
                 class: "ml-2.5 whitespace-nowrap") { @title }
            trailing
          end
        end

        private

        def link_variant
          return :disabled if @disabled

          @current ? :sidebar_current : :sidebar
        end

        # Renders the trailing element of an item.
        def trailing
          return count_badge if @count
          return unless @badge

          span(data_sidebar_target: "linkText",
               class: "ml-auto text-[10.5px] font-medium text-line-strong") do
            @badge
          end
        end

        # Renders the count, when the row has one.
        #
        # Zero is considered a count. Use `nil` when the row shouldn't carry a
        # count.
        def count_badge
          color = @current ? "text-accent-muted" : "text-muted-foreground"

          span(data_sidebar_target: "linkText",
               class: "ml-auto text-[11.5px] font-medium tabular-nums #{color}") do
            @count.to_s
          end
        end

        def default_attrs
          attrs = {
            data: { sidebar_target: "row" },
            class: "w-full justify-start h-[34px] px-[11px] rounded-lg"
          }
          attrs[:aria] = { current: "page" } if @current && !@disabled
          attrs
        end
      end
    end
  end
end
