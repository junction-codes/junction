# frozen_string_literal: true

# Index view for deployments.
class Views::Deployments::Index < Views::Base
  attr_reader :available_components, :available_environments,
              :available_platforms, :deployments, :query

  # Initializes the view.
  #
  # @param deployments [ActiveRecord::Relation] Collection of deployments to
  #  display.
  # @param query [Ransack::Search] Ransack query object for filtering and
  #   sorting.
  # @param available_components [ActiveRecord::Relation] Component entity
  #   options with name and id attributes.
  # @param available_environments [Array<Array>] Environment options as
  #   [label, value] pairs for filtering.
  # @param available_platforms [Array<Array>] Platform options as [label,
  #   value] pairs for filtering.
  def initialize(deployments:, query:, available_components:,
    available_environments:, available_platforms:)
    @deployments = deployments
    @query = query
    @available_components = available_components
    @available_environments = available_environments
    @available_platforms = available_platforms
  end

  def view_template
    render Junction::Layouts::Application do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Deployments" }
          Link(variant: :primary, href: new_deployment_path) do
            "New Deployment"
          end
        end

        Components::DeploymentFilters(query:, available_components:,
                                      available_environments:, available_platforms:)

        div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
          render Components::Table do |table|
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
            Link(href: component_path(deployment.component), class: "ps-0") do
              deployment.component.name
            end
          end

          row.cell do
            if deployment.component.owner.present?
              render Link(href: group_path(deployment.component.owner)) { deployment.component.owner.name }
            end
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
