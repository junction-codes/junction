# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Index view for resources.
      class Index < Views::Base
        attr_reader :available_owners, :available_systems, :available_types,
                    :query, :resources

        # Initializes the view.
        #
        # @param resources [ActiveRecord::Relation] Collection of resources to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with name
        #   and id attributes.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        def initialize(resources:, query:, available_owners:, available_systems:,
                      available_types:)
          @resources = resources
          @query = query
          @available_owners = available_owners
          @available_systems = available_systems
          @available_types = available_types
        end

        def view_template
          render Junction::Layouts::Application do
            div(class: "p-6") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Resources" }
                Link(variant: :primary, href: new_resource_path) do
                  "New Resource"
                end
              end

              ResourceFilters(query:, available_owners:,
                                            available_systems:, available_types:)

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
              sort_url = ->(field, direction) { resources_path(q: { s: "#{field} #{direction}" }) }

              row.sortable_head(query:, field: "name", sort_url:) { "Resource" }
              row.sortable_head(query:, field: "system_id", sort_url:) { "System" }
              row.sortable_head(query:, field: "owner_id", sort_url:) { "Owner" }
              row.sortable_head(query:, field: "type", sort_url:) { "Type" }
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
                      div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                        a(href: resource_path(resource)) { resource.name }
                      end

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
              end
            end
          end
        end
      end
    end
  end
end
