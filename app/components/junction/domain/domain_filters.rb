# frozen_string_literal: true

module Junction
  module Components
    module Domain
      # Renders filters available when searching Domain entities.
      class DomainFilters < Base
        # Initializes the component.
        #
        # @param query [Ransack::Search] Ransack query object for filtering.
        # @param available_owners [ActiveRecord::Relation] Owner options with
        #   name and id attributes for filtering.
        # @param available_statuses [Array<Array>] Status options as [label,
        #   value] pairs for filtering.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(query:, available_owners: [], available_statuses: [],
                       **user_attrs)
          @query = query
          @available_owners = available_owners
          @available_statuses = available_statuses

          super(**user_attrs)
        end

        def view_template(&)
          render Table::FilterBar.new(
            query: @query,
            action_url: domains_path,
            clear_url: domains_path
          ) do |bar|
            div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
              bar.text_filter(
                name: "q[title_or_description_cont]",
                label: t(".search"),
                placeholder: t(".placeholder"),
                value: @query.title_or_description_cont
              )

              bar.select_filter(
                name: "q[status_eq]",
                label: Junction::Domain.human_attribute_name(:status),
                options: @available_statuses,
                selected: @query.status_eq,
                include_blank: true,
                blank_label: t(
                  ".all",
                  label: Junction::Domain.human_attribute_name(:status).pluralize
                )
              ) if @available_statuses.any?

              bar.entity_filter(
                name: "q[owner_id_eq]",
                label: Junction::Domain.human_attribute_name(:owner_id),
                entities: @available_owners,
                selected: @query.owner_id_eq,
                include_blank: true,
                blank_label: t(
                  ".all",
                  label: Junction::Domain.human_attribute_name(:owner_id).pluralize
                )
              ) if @available_owners.any?
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
