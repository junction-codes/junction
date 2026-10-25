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
            class: "border border-border rounded-md overflow-hidden " \
                   "divide-y divide-border"
          }
        end
      end
    end
  end
end
