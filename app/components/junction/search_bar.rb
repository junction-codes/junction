# frozen_string_literal: true

module Junction
  module Components
    # Header search bar with live autocomplete dropdown.
    class SearchBar < Base
      DEFAULT_INPUT_CLASSES = [
        "w-96 pl-10 pr-4 py-2 rounded-md border border-gray-300",
        "dark:border-gray-600 bg-gray-50 dark:bg-gray-700",
        "text-gray-900 dark:text-gray-200 focus:outline-none",
        "focus:ring-2 focus:ring-blue-500"
      ].freeze

      # Initializes a new component.
      #
      # @param input_class [String] Classes for the input, replacing the
      #   defaults
      # @param user_attrs [Hash] Additional HTML attributes.
      def initialize(input_class: nil, **user_attrs)
        @input_class = input_class

        super(**user_attrs)
      end

      def view_template
        div(data: data_attrs, **attrs) do
          form(action: search_path, method: :get) do
            input(
              type: "search",
              name: "q",
              placeholder: t(".placeholder"),
              aria_label: t(".placeholder"),
              autocomplete: "off",
              data: {
                header_search_target: "input",
                action: "input->header-search#search keydown.escape->header-search#clearResults"
              },
              class: @input_class || DEFAULT_INPUT_CLASSES
            )

            span(class: "absolute left-3 top-1/2 -translate-y-1/2 " \
                        "text-muted-foreground") do
              icon("search", class: "w-4 h-4")
            end
          end

          turbo_frame_tag "global-search-results", data: { header_search_target: "results" }
        end
      end

      private

      def data_attrs
        {
          controller: "header-search",
          header_search_search_url_value: search_autocomplete_path,
          action: "click@document->header-search#clickOutside"
        }
      end

      def default_attrs
        {
          class: "relative"
        }
      end
    end
  end
end
