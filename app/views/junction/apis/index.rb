# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Index view for APIs.
      class Index < Views::Base
        attr_reader :apis, :available_lifecycles, :available_owners,
                    :available_systems, :available_types, :breadcrumbs,
                    :can_create, :pagy, :query, :query_params

        # Initializes the view.
        #
        # @param apis [ActiveRecord::Relation] Collection of APIs to display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_lifecycles [Array<Array>] Lifecycle options as
        #   [label, value] pairs for filtering.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with name
        #   and id attributes.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param can_create [Boolean] Whether the user can create APIs.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(apis:, query:, pagy:, available_lifecycles:,
                       available_owners:, available_systems:, available_types:,
                       can_create: true, breadcrumbs: [], query_params: {})
          @apis = apis
          @query = query
          @query_params = query_params
          @pagy = pagy
          @available_lifecycles = available_lifecycles
          @available_owners = available_owners
          @available_systems = available_systems
          @available_types = available_types
          @can_create = can_create
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                  Junction::Api.model_name.human(count: 2)
                end

                if @can_create
                  Link(variant: :primary, href: new_api_path) { t(".new") }
                end
              end

              ApiFilters(query:, available_lifecycles:, available_owners:,
                                     available_systems:, available_types:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { apis_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { apis_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                apis_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[title system_id owner_id type lifecycle].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  Api.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @apis.each do |api|
              body.row do |row|
                row.cell { EntityPreview(entity: api) }
                row.cell { render_view_link(api.system, class: "ps-0") }
                row.cell { render_view_link(api.owner, class: "ps-0") }

                row.cell do
                  break unless api.type.present?

                  if Junction::CatalogOptions.apis.key?(api.type)
                    Junction::CatalogOptions.apis[api.type][:name]
                  else
                    api.type.capitalize
                  end
                end

                row.cell do
                  Badge(variant: api.lifecycle&.to_sym) { api.lifecycle&.titleize }
                end
              end
            end
          end
        end
      end
    end
  end
end
