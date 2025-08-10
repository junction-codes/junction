# frozen_string_literal: true

class Views::Deployments::Index < Views::Base
  def initialize(deployments:)
    @deployments = deployments
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Deployments" }
          Link(variant: :primary, href: new_deployment_path) do
            "New Deployment"
          end
        end

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
        row.head { "Component" }
        row.head { "Environment" }
        row.head { "Platform" }
        row.head { "Identifier" }
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
            Link(href: component_path(deployment.component), class: 'ps-0') do
              deployment.component.name
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
