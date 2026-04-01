# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Index view for resources.
      class Index < Views::Base
        attr_reader :available_owners, :available_systems, :available_types,
                    :breadcrumbs, :can_create, :pagy, :query, :query_params,
                    :resources

        # Initializes the view.
        #
        # @param resources [ActiveRecord::Relation] Collection of resources to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with
        #   name and id attributes.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param can_create [Boolean] Whether the user can create resources.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(resources:, query:, pagy:, available_owners:,
                       available_systems:, available_types:, can_create: true,
                       breadcrumbs: [], query_params: {})
          @resources = resources
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @available_owners = available_owners
          @available_systems = available_systems
          @available_types = available_types
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Resources" }
                if @can_create
                  Link(variant: :primary, href: new_resource_path) { "New Resource" }
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

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { resources_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { resources_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                resources_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

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
                row.cell { EntityPreview(entity: resource) }
                row.cell { render_view_link(resource.system, class: "ps-0") }
                row.cell { render_view_link(resource.owner, class: "ps-0") }

                row.cell do
                  break unless resource.type.present?

                  if Junction::CatalogOptions.resources.key?(resource.type)
                    Junction::CatalogOptions.resources[resource.type][:name]
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
