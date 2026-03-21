# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a per-page selector to support pagination.
    class PerPageSelector < Base
      # Initializes a new component.
      #
      # @param per_page_url [#call] Callback that accepts a per-page integer and
      #   returns a URL string.
      # @param current [Integer] The current per-page setting.
      # @param options [Array<Integer>] Available per-page options.
      # @param total [Integer] The total number of results.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(per_page_url:,
                     current: Junction::Paginatable::DEFAULT_PER_PAGE,
                     options: Junction::Paginatable::ALLOWED_PER_PAGE,
                     total: 0, **user_attrs)
        @per_page_url = per_page_url
        @current = current
        @options = options
        @total = total

        super(**user_attrs)
      end

      def view_template(&)
        div(class: "flex items-center justify-between text-sm text-gray-600 dark:text-gray-400", **attrs) do
          div(class: "flex items-center gap-2") do
            span { t("components.pagination.rows_per_page") }

            @options.each do |option|
              if option == @current
                span(class: "px-2 py-1 rounded border border-input bg-accent font-medium") { option.to_s }
              else
                Link(
                  href: @per_page_url.call(option),
                  variant: :ghost,
                  class: "px-2 py-1 rounded hover:bg-accent hover:text-accent-foreground",
                  data: { turbo_action: "advance" }
                ) { option.to_s }
              end
            end
          end

          span { t("components.pagination.total_results", count: @total) }
        end
      end
    end
  end
end
