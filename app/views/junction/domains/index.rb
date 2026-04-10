# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Index view for domains.
      class Index < Views::Base
        attr_reader :available_owners, :available_statuses, :breadcrumbs,
                     :can_create, :domains, :pagy, :query, :query_params

        # Initializes the view.
        #
        # @param domains [ActiveRecord::Relation] Collection of domains to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_statuses [Array<Array>] Status options as [label,
        #   value] pairs for filtering.
        # @param can_create [Boolean] Whether the user can create domains.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(domains:, query:, pagy:, available_owners:,
                       available_statuses:, can_create: true, breadcrumbs: [],
                       query_params: {})
          @domains = domains
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @available_owners = available_owners
          @available_statuses = available_statuses
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              # Page header.
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Domains" }
                if @can_create
                  Link(variant: :primary, href: new_domain_path) { "New Domain" }
                end
              end

              DomainFilters(query:, available_owners:, available_statuses:)

              # Domains table.
              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { domains_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { domains_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                domains_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[title status owner_id].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  Domain.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @domains.each do |domain|
              body.row do |row|
                row.cell { EntityPreview(entity: domain) }

                row.cell do
                  Badge(variant: domain.status&.to_sym) { domain.status&.titleize }
                end

                row.cell { render_view_link(domain.owner, class: "ps-0") }
              end
            end
          end
        end
      end
    end
  end
end
