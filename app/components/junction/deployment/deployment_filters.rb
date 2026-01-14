# frozen_string_literal: true

module Junction
  module Components
    # Renders filters available when searching Deployment entities.
    class DeploymentFilters < Base
      # Initializes the component.
      #
      # @param query [Ransack::Search] Ransack query object for filtering.
      # @param available_components [ActiveRecord::Relation] Component options
      #   with name and id attributes for filtering.
      # @param available_environments [Array<Array>] Environment options as
      #   [label, value] pairs for filtering.
      # @param available_platforms [Array<Array>] Platform options as [label,
      #   value] pairs for filtering.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(query:, available_components: [], available_environments: [],
                    available_platforms: [], **user_attrs)
        @query = query
        @available_components = available_components
        @available_environments = available_environments
        @available_platforms = available_platforms

        super(**user_attrs)
      end

      def view_template(&)
        render Components::TableFilterBar.new(
          query: @query,
          action_url: deployments_path,
          clear_url: deployments_path
        ) do |bar|
          div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
            # TODO: Can we search component name or description here?
            bar.text_filter(
              name: "q[location_identifier_cont]",
              label: "Identifier",
              placeholder: "Identifier...",
              value: @query.location_identifier_cont
            )

            bar.entity_filter(
              name: "q[component_id_eq]",
              label: "Component",
              entities: @available_components,
              selected: @query.component_id_eq,
              include_blank: true,
              blank_label: "All Components"
            ) if @available_components.any?

            bar.select_filter(
              name: "q[environment_eq]",
              label: "Environment",
              options: @available_environments,
              selected: @query.environment_eq,
              include_blank: true,
              blank_label: "All Environments"
            ) if @available_environments.any?

            bar.select_filter(
              name: "q[platform_eq]",
              label: "Platform",
              options: @available_platforms,
              selected: @query.platform_eq,
              include_blank: true,
              blank_label: "All Platforms"
            ) if @available_platforms.any?
          end

          div(class: "flex gap-2") do
            bar.actions
          end
        end
      end
    end
  end
end
