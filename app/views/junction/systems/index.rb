# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Index view for Systems.
      class Index < Views::Base
        attr_reader :available_domains, :available_owners, :available_statuses,
                    :breadcrumbs, :can_create, :pagy, :query, :query_params,
                    :systems

        # Initializes the view.
        #
        # @param systems [ActiveRecord::Relation] Collection of systems to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_domains [Array<Array>] Domain entity options with
        #   name and id attributes.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_statuses [Array<Array>] Status options as [label,
        #   value] pairs for filtering.
        # @param can_create [Boolean] Whether the user can create systems.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(systems:, query:, pagy:, available_domains:,
                       available_owners:, available_statuses:, can_create: true,
                       breadcrumbs: [], query_params: {})
          @systems = systems
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @available_domains = available_domains
          @available_owners = available_owners
          @available_statuses = available_statuses
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                  Junction::System.model_name.human(count: 2)
                end

                if @can_create
                  Link(variant: :primary, href: new_system_path) { t(".new") }
                end
              end

              SystemFilters(query:, available_domains:, available_owners:,
                                          available_statuses:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { systems_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { systems_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                systems_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[title owner_id domain_id status].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  System.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @systems.each do |system|
              body.row do |row|
                row.cell { EntityPreview(entity: system) }
                row.cell { render_view_link(system.owner, class: "ps-0") }
                row.cell { render_view_link(system.domain, class: "ps-0") }

                row.cell do
                  Badge(variant: system.status&.to_sym) { system.status&.capitalize }
                end
              end
            end
          end
        end
      end
    end
  end
end
