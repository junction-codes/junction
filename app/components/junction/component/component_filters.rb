# frozen_string_literal: true

module Junction
  module Components
    # Renders filters available when searching Component entities.
    class ComponentFilters < Base
      # Initializes the component.
      #
      # @param query [Ransack::Search] Ransack query object for filtering.
      # @param available_lifecycles [Array<Array>] Lifecycle options as [label,
      #   value] pairs for filtering.
      # @param available_owners [ActiveRecord::Relation] Owner options with name
      #   and id attributes for filtering.
      # @param available_systems [ActiveRecord::Relation] System options with name
      #   and id attributes for filtering.
      # @param available_types [Array<Array>] Type options as [label, value] pairs
      #   for filtering.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(query:, available_lifecycles: [], available_owners: [],
                    available_systems: [], available_types: [], **user_attrs)
        @query = query
        @available_lifecycles = available_lifecycles
        @available_owners = available_owners
        @available_systems = available_systems
        @available_types = available_types

        super(**user_attrs)
      end

      def view_template(&)
        render Components::TableFilterBar.new(
          query: @query,
          action_url: components_path,
          clear_url: components_path
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

            bar.entity_filter(
              name: "q[system_id_eq]",
              label: "System",
              entities: @available_systems,
              selected: @query.system_id_eq,
              include_blank: true,
              blank_label: "All Systems"
            ) if @available_systems.any?

            bar.entity_filter(
              name: "q[owner_id_eq]",
              label: "Owner",
              entities: @available_owners,
              selected: @query.owner_id_eq,
              include_blank: true,
              blank_label: "All Owners"
            ) if @available_owners.any?

            bar.select_filter(
              name: "q[lifecycle_eq]",
              label: "Lifecycle",
              options: @available_lifecycles,
              selected: @query.lifecycle_eq,
              include_blank: true,
              blank_label: "All Lifecycles"
            ) if @available_lifecycles.any?
          end

          div(class: "flex gap-2") do
            bar.actions
          end
        end
      end
    end
  end
end
