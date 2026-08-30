# frozen_string_literal: true

module Junction
  module Components
    module System
      # Renders filters available when searching System entities.
      class SystemFilters < Base
        # Initializes the component.
        #
        # @param query [Ransack::Search] Ransack query object for filtering.
        # @param available_domains [ActiveRecord::Relation] Domain options with
        #   name and id attributes for filtering.
        # @param available_owners [ActiveRecord::Relation] Owner options with
        #   name and id attributes for filtering.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   for filtering.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(query:, available_domains: [], available_owners: [],
                       available_types: [], **user_attrs)
          @query = query
          @available_domains = available_domains
          @available_owners = available_owners
          @available_types = available_types

          super(**user_attrs)
        end

        def view_template(&)
          render Table::FilterBar.new(
            query: @query,
            action_url: systems_path,
            clear_url: systems_path
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
                label: Junction::System.human_attribute_name(:type),
                options: @available_types,
                selected: @query.type_eq,
                include_blank: true,
                blank_label: t(".all",
                  label: Junction::System.human_attribute_name(:type).pluralize
                )
              ) if @available_types.any?

              bar.entity_filter(
                name: "q[owner_id_eq]",
                label: Junction::System.human_attribute_name(:owner_id),
                entities: @available_owners,
                selected: @query.owner_id_eq,
                include_blank: true,
                blank_label: t(".all",
                  label: Junction::System.human_attribute_name(:owner_id).pluralize
                )
              ) if @available_owners.any?

              bar.entity_filter(
                name: "q[domain_id_eq]",
                label: Junction::System.human_attribute_name(:domain_id),
                entities: @available_domains,
                selected: @query.domain_id_eq,
                include_blank: true,
                blank_label: t(".all",
                  label: Junction::System.human_attribute_name(:domain_id).pluralize
                )
              ) if @available_domains.any?
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
