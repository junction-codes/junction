# frozen_string_literal: true

module Junction
  module Views
    module Deployments
      # Index view for deployments.
      class Index < Views::Base
        attr_reader :available_components, :available_environments,
                    :available_platforms, :can_create, :deployments, :query

        # Initializes the view.
        #
        # @param deployments [ActiveRecord::Relation] Collection of deployments
        #   to display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param available_components [ActiveRecord::Relation] Component entity
        #   options with name and id attributes.
        # @param available_environments [Array<Array>] Environment options as
        #   [label, value] pairs for filtering.
        # @param available_platforms [Array<Array>] Platform options as [label,
        #   value] pairs for filtering.
        # @param can_create [Boolean] Whether the user can create deployments.
        def initialize(deployments:, query:, available_components:,
          available_environments:, available_platforms:, can_create: true)
          @deployments = deployments
          @query = query
          @can_create = can_create
          @available_components = available_components
          @available_environments = available_environments
          @available_platforms = available_platforms
        end

        def view_template
          render Junction::Layouts::Application do
            div(class: "p-6") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Deployments" }
                if @can_create
                  Link(variant: :primary, href: new_deployment_path) { "New Deployment" }
                end
              end

              DeploymentFilters(query:, available_components:,
                                              available_environments:, available_platforms:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                render Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) { deployments_path(q: { s: "#{field} #{direction}" }) }

              row.sortable_head(query:, field: "component_id", sort_url:) { "Component" }
              row.sortable_head(query:, field: "owner_id", sort_url:) { "Owner" }
              row.sortable_head(query:, field: "environment", sort_url:) { "Environment" }
              row.sortable_head(query:, field: "platform", sort_url:) { "Platform" }
              row.sortable_head(query:, field: "location_identifier", sort_url:) { "Identifier" }

              row.head(class: "relative") do
                span(class: "sr-only") { "View" }
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @deployments.each do |deployment|
              body.row do |row|
                row.cell do
                  render_view_link(deployment.component, class: "ps-0")
                end

                row.cell do
                  render_view_link(deployment.component.owner, class: "ps-0")
                end

                row.cell { deployment.environment }
                row.cell { deployment.platform }
                row.cell { deployment.location_identifier }

                row.cell(class: "text-right text-sm font-medium") do
                  a(href: deployment_path(deployment), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end
end
