# frozen_string_literal: true

module Junction
  module Components
    # Header search bar with live autocomplete dropdown.
    class SearchBar < Base
      def view_template
        div(data: data_attrs, **attrs) do
          form(action: search_path, method: :get) do
            input(
              type: "search",
              name: "q",
              placeholder: t(".placeholder"),
              autocomplete: "off",
              data: {
                header_search_target: "input",
                action: "input->header-search#search keydown.escape->header-search#clearResults"
              },
              class: "w-96 pl-10 pr-4 py-2 rounded-md border border-gray-300 " \
                     "dark:border-gray-600 bg-gray-50 dark:bg-gray-700 " \
                     "text-gray-900 dark:text-gray-200 focus:outline-none " \
                     "focus:ring-2 focus:ring-blue-500"
            )

            span(class: "absolute left-3 top-1/2 -translate-y-1/2 text-gray-400") do
              icon("search", class: "w-5 h-5")
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
