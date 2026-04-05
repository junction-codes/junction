# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Index view for groups.
      class Index < Views::Base
        attr_reader :available_types, :breadcrumbs, :can_create, :groups,
                    :pagy, :query, :query_params

        # Initializes the view.
        #
        # @param groups [ActiveRecord::Relation] Collection of groups to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering
        #   and sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param can_create [Boolean] Whether the user can create groups.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(groups:, query:, pagy:, available_types:,
                       can_create: true, breadcrumbs: [], query_params: {})
          @groups = groups
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @available_types = available_types
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Groups" }
                if @can_create
                  Link(variant: :primary, href: new_group_path) { "New Group" }
                end
              end

              GroupFilters(query:, available_types:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                render Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { groups_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { groups_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                groups_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[title type email parent_id].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  Group.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @groups.each do |group|
              body.row do |row|
                row.cell { EntityPreview(entity: group) }

                row.cell do
                  break unless group.type.present?

                  if Junction::CatalogOptions.group_types.key?(group.type)
                    Junction::CatalogOptions.group_types[group.type][:name]
                  else
                    group.type.capitalize
                  end
                end

                row.cell do group.email
                  Link(href: "mailto:#{group.email}", class: "ps-0") { group.email } if group.email.present?
                end

                row.cell do
                  render_view_link(group.parent, class: "ps-0") if group.parent.present?
                end
              end
            end
          end
        end
      end
    end
  end
end
