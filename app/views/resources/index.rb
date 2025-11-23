# frozen_string_literal: true

module Views
  module Resources
    class Index < Views::Base
      def initialize(resources:)
        @resources = resources
      end

      def view_template
        render Layouts::Application.new do
          div(class: "p-6") do
            div(class: "flex justify-between items-center mb-6") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Resources" }
              Link(variant: :primary, href: new_resource_path) do
                "New Resource"
              end
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              render ::Components::Table do |table|
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
            row.head { "Name" }
            row.head { "System" }
            row.head { "Owner" }
            row.head { "Type" }
            row.head(class: "relative") do
              span(class: "sr-only") { "View" }
            end
          end
        end
      end

      def table_body(table)
        table.body do |body|
          @resources.each do |resource|
            body.row do |row|
              row.cell do
                div(class: "flex items-center space-x-4") do
                  # Logo or placeholder image.
                  if resource.image_url.present?
                    img(src: resource.image_url, alt: "#{resource.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
                  else
                    div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                      icon(resource.icon, class: "h-6 w-6 text-gray-500")
                    end
                  end

                  div do
                    div(class: "text-sm font-medium text-gray-900 dark:text-white") { resource.name }
                    div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { resource.description }
                  end
                end
              end

              row.cell do
                Link(href: system_path(resource.system), class: "ps-0") { resource.system.name } if resource.system.present?
              end

              row.cell do
                Link(href: group_path(resource.owner)) { resource.owner.name } if resource.owner.present?
              end

              row.cell do
                break unless resource.type.present?

                if CatalogOptions.resources.key?(resource.type)
                  CatalogOptions.resources[resource.type][:name]
                else
                  resource.type.capitalize
                end
              end

              row.cell(class: "text-right text-sm font-medium") do
                a(href: resource_path(resource), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
              end
            end
          end
        end
      end
    end
  end
end
