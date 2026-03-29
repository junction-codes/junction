# frozen_string_literal: true

module Junction
  module Components
    # Container for autocomplete search results.
    #
    # @example
    #   AutocompleteResultList do
    #     @results.each do |item|
    #       AutocompleteResultItem(value: item.id, name: item.name) { item.subtitle }
    #     end
    #   end
    class AutocompleteResultList < Base
      def view_template
        ul(**attrs) { yield }
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
