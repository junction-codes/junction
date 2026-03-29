# frozen_string_literal: true

module Junction
  module Components
    # Empty state for autocomplete search results.
    #
    # @example
    #   AutocompleteResultEmpty do
    #     "No results found"
    #   end
    class AutocompleteResultEmpty < Base
      def view_template
        div(**attrs) do
          p(class: "px-3 py-4 text-sm text-gray-500 dark:text-gray-400 text-center") do
            yield
          end
        end
      end

      private

      def default_attrs
        {
          class: "border border-gray-200 dark:border-gray-600 rounded-md"
        }
      end
    end
  end
end
