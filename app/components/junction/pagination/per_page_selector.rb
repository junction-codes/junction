# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display a per-page selector to support pagination.
      class PerPageSelector < Base
        # Initializes a new component.
        #
        # @param per_page_url [#call] Callback that accepts a per-page integer
        #   and returns a URL string.
        # @param current [Integer] The current per-page setting.
        # @param options [Array<Integer>] Available per-page options.
        # @param total [Integer, nil] The total number of results, or `nil` to
        #   skip displaying the total.
        # @param turbo_action [String] Turbo action to use for pagination links.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(per_page_url:,
                       current: Junction::Paginatable::DEFAULT_PER_PAGE,
                       options: Junction::Paginatable::ALLOWED_PER_PAGE,
                       total: 0, turbo_action: "advance", **user_attrs)
          @per_page_url = per_page_url
          @current = current
          @options = options
          @total = total
          @turbo_action = turbo_action

          super(**user_attrs)
        end

        def view_template(&)
          div(class: "flex items-center gap-4 text-[12.5px] text-text-tertiary",
              **attrs) do
            div(class: "flex items-center gap-1") do
              span { t(".per_page") }

              @options.each do |option|
                if option == @current
                  span(class: "px-2 py-0.5 rounded-lg bg-accent " \
                              "text-accent-foreground font-semibold") { option.to_s }
                else
                  Link(
                    href: @per_page_url.call(option),
                    variant: :ghost,
                    class: "h-auto px-2 py-0.5 rounded-lg text-[12.5px] " \
                           "hover:bg-subtle",
                    data: { turbo: { action: @turbo_action }.compact }
                  ) { option.to_s }
                end
              end
            end

            span { t(".total", count: @total) } if @total
          end
        end
      end
    end
  end
end
