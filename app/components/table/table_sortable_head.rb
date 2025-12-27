# frozen_string_literal: true

module Components
  # Sortable table head component.
  class TableSortableHead < Base
    # Initializes the components.
    #
    # @param query [Ransack::Search] Ransack query object for sorting.
    # @param field [String] The field name to sort by.
    # @param sort_url [Proc] A proc that generates the sort URL given field and
    #   direction.
    # @param user_attrs [Hash] Additional HTML attributes for the component.
    def initialize(query:, field:, sort_url:, **user_attrs)
      @query = query
      @field = field
      @sort_url = sort_url

      super(**user_attrs)
    end

    def view_template(&block)
      TableHead(**attrs) do
        a(
          href: @sort_url.call(@field, direction_next),
          class: "inline-flex items-center gap-2 hover:text-blue-600 dark:hover:text-blue-400 cursor-pointer"
        ) do
          span(&block)

          if sorted?
            span(class: "text-sm") { direction_current == "asc" ? "↑" : "↓" }
          end
        end
      end
    end

    private

    # Determines the current sort direction.
    #
    # @return [String] Current sort direction.
    def direction_current
      @query.sorts.first&.dir == "asc" ? "asc" : "desc"
    end

    # Determines the next sort direction.
    #
    # @return [String] Next sort direction.
    def direction_next
      sorted? && direction_current == "asc" ? "desc" : "asc"
    end

    # Whether the column is currently sorted.
    #
    # @return [Boolean] True if the column is currently sorted.
    def sorted?
      @query.sorts.first&.name == @field
    end
  end
end
