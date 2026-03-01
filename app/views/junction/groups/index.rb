# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Index view for groups.
      class Index < Views::Base
        attr_reader :available_types, :can_create, :groups, :query

        # Initializes the view.
        #
        # @param groups [ActiveRecord::Relation] Collection of groups to
        #   display.
        # @param query [Ransack::Search] Ransack query object for filtering
        #   and sorting.
        # @param available_types [Array<Array>] Type options as [label, value]
        #   pairs for filtering.
        # @param can_create [Boolean] Whether the user can create groups.
        def initialize(groups:, query:, available_types:, can_create: true)
          @groups = groups
          @query = query
          @can_create = can_create
          @available_types = available_types
        end

        def view_template
          render Junction::Layouts::Application.new do
            div(class: "p-6") do
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
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) { groups_path(q: { s: "#{field} #{direction}" }) }

              row.sortable_head(query:, field: "name", sort_url:) { "Group" }
              row.sortable_head(query:, field: "type", sort_url:) { "Type" }
              row.sortable_head(query:, field: "email", sort_url:) { "Email" }
              row.sortable_head(query:, field: "parent_id", sort_url:) { "Parent" }
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @groups.each do |group|
              body.row do |row|
                row.cell do
                  div(class: "flex items-center space-x-4") do
                    # Logo or placeholder image.
                    if group.image_url.present?
                      img(src: group.image_url, alt: "#{group.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
                    else
                      div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                        icon(group.icon, class: "h-6 w-6 text-gray-500")
                      end
                    end

                    div do
                      div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                        render_view_link(group, class: "ps-0")
                      end

                      div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { group.description }
                    end
                  end
                end

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
                  if group.parent
                    render_view_link(group.parent, class: "ps-0")
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
