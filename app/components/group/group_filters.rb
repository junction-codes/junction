# frozen_string_literal: true

module Components
  # Renders filters available when searching Group entities.
  class GroupFilters < Base
    # Initializes the component.
    #
    # @param query [Ransack::Search] Ransack query object for filtering.
    # @param available_types [Array<Array>] Type options as [label, value] paris
    #   for filtering.
    # @param user_attrs [Hash] Additional HTML attributes for the component.
    def initialize(query:, available_types: [], **user_attrs)
      @query = query
      @available_types = available_types

      super(**user_attrs)
    end

    def view_template(&)
      render Components::TableFilterBar.new(
        query: @query,
        action_url: groups_path,
        clear_url: groups_path
      ) do |bar|
        div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
          bar.text_filter(
            name: "q[name_or_description_cont]",
            label: "Search",
            placeholder: "Name or description...",
            value: @query.name_or_description_cont
          )

          bar.select_filter(
            name: "q[type_eq]",
            label: "Type",
            options: @available_types,
            selected: @query.type_eq,
            include_blank: true,
            blank_label: "All Types"
          ) if @available_types.any?
        end

        div(class: "flex gap-2") do
          bar.actions
        end
      end
    end
  end
end
