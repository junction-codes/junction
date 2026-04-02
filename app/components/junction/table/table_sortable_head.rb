# frozen_string_literal: true

module Junction
  module Components
    # Sortable table head component.
    class TableSortableHead < Base
      # Initializes the component.
      #
      # @param field [String] The field name to sort by.
      # @param sort_url [Proc] A proc that generates the sort URL given field
      #   and direction.
      # @param sorted [Boolean] Whether this column is currently sorted.
      # @param direction [String] Current direction when sorted.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(field:, sort_url:, sorted: false, direction: "asc",
                     **user_attrs)
        @field = field
        @sort_url = sort_url
        @sorted = sorted
        @direction = direction

        super(**user_attrs)
      end

      def view_template(&block)
        TableHead(**attrs) do
          a(
            href: @sort_url.call(@field, next_direction),
            class: "inline-flex items-center gap-2 hover:text-blue-600 dark:hover:text-blue-400 cursor-pointer"
          ) do
            span(&block)
            next unless @sorted

            span(class: "text-sm") { @direction == "asc" ? "↑" : "↓" }
          end
        end
      end

      private

      # Determines the next sort direction.
      #
      # @return [String] Next sort direction.
      def next_direction
        @sorted && @direction == "asc" ? "desc" : "asc"
      end
    end
  end
end
