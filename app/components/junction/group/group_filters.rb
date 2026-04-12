# frozen_string_literal: true

module Junction
  module Components
    module Group
      # Renders filters available when searching Group entities.
      class GroupFilters < Base
        # Initializes the component.
        #
        # @param query [Ransack::Search] Ransack query object for filtering.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(query:, available_types: [], **user_attrs)
          @query = query
          @available_types = available_types

          super(**user_attrs)
        end

        def view_template(&)
          render Table::FilterBar.new(
            query: @query,
            action_url: groups_path,
            clear_url: groups_path
          ) do |bar|
            div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
              bar.text_filter(
                name: "q[title_or_description_cont]",
                label: t(".search"),
                placeholder: t(".placeholder"),
                value: @query.title_or_description_cont
              )

              bar.select_filter(
                name: "q[type_eq]",
                label: Junction::Group.human_attribute_name(:type),
                options: @available_types,
                selected: @query.type_eq,
                include_blank: true,
                blank_label: t(
                  ".all",
                  label: Junction::Group.human_attribute_name(:type).pluralize
                )
              ) if @available_types.any?
            end

            div(class: "flex gap-2") do
              bar.actions
            end
          end
        end
      end
    end
  end
end
