# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Index view for components.
      class Index < Views::Base
        attr_reader :available_lifecycles, :available_owners,
                    :available_systems, :available_types, :breadcrumbs,
                    :can_create, :components, :pagy, :query, :query_params

        # Initializes the view.
        #
        # @param components [ActiveRecord::Relation] Collection of components to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_lifecycles [Array<Array>] Lifecycle options as
        #   [label, value] pairs for filtering.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with
        #   name and id attributes.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param can_create [Boolean] Whether the user can create components.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(components:, query:, pagy:, available_lifecycles:,
                       available_owners:, available_systems:, available_types:,
                       can_create: true, breadcrumbs: [], query_params: {})
          @components = components
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @available_lifecycles = available_lifecycles
          @available_owners = available_owners
          @available_systems = available_systems
          @available_types = available_types
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                  Junction::Component.model_name.human(count: 2)
                end

                if @can_create
                  Link(variant: :primary, href: new_component_path) { t(".new") }
                end
              end

              ComponentFilters(query:, available_lifecycles:,
                                          available_owners:, available_systems:,
                                          available_types:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { components_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { components_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                components_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[title system_id owner_id type lifecycle].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  Component.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @components.each do |component|
              body.row do |row|
                row.cell { EntityPreview(entity: component) }
                row.cell { render_view_link(component.system, class: "ps-0") }
                row.cell { render_view_link(component.owner, class: "ps-0") }

                row.cell do
                  break unless component.type.present?

                  if Junction::CatalogOptions.kinds.key?(component.type)
                    Junction::CatalogOptions.kinds[component.type][:name]
                  else
                    component.type.capitalize
                  end
                end

                row.cell do
                  Badge(variant: component.lifecycle&.to_sym) { component.lifecycle&.capitalize }
                end
              end
            end
          end
        end
      end
    end
  end
end
