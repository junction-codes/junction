# frozen_string_literal: true

module Junction
  module Components
    module Autocomplete
      # Container for autocomplete search results.
      #
      # @example
      #   ResultList do
      #     @results.each do |item|
      #       ResultItem(value: item.id, name: item.name) { item.subtitle }
      #     end
      #   end
      class ResultList < Base
        def view_template
          ul(**attrs) { yield }
        end

        def item(...)
          render ResultItem.new(...)
        end

        private

        def default_attrs
          {
            role: "listbox",
            class: "border border-gray-200 dark:border-gray-600 rounded-md " \
                   "overflow-hidden divide-y divide-gray-100 dark:divide-gray-700"
          }
        end
      end
    end
  end
end
