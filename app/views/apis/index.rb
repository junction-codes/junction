# frozen_string_literal: true

# Index view for APIs.
class Views::Apis::Index < Views::Base
  attr_reader :apis, :available_lifecycles, :available_owners,
              :available_systems, :available_types, :query

  # Initializes the view.
  #
  # @param apis [ActiveRecord::Relation] Collection of APIs to display.
  # @param query [Ransack::Search] Ransack query object for filtering and
  #   sorting.
  # @param available_lifecycles [Array<Array>] Lifecycle options as [label,
  #   value] pairs for filtering.
  # @param available_owners [ActiveRecord::Relation] Owner entity options with
  #   name and id attributes.
  # @param available_systems [ActiveRecord::Relation] System entity options with
  #   name and id attributes.
  # @param available_types [Array<Array>] Type options as [label, value] pairs
  #   for filtering.
  def initialize(apis:, query:, available_lifecycles:, available_owners:,
                 available_systems:, available_types:)
    @apis = apis
    @query = query
    @available_lifecycles = available_lifecycles
    @available_owners = available_owners
    @available_systems = available_systems
    @available_types = available_types
  end

  def view_template
    render Layouts::Application do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "APIs" }
          Link(variant: :primary, href: new_api_path) do
            "New API"
          end
        end

        Components::ApiFilters(query:, available_lifecycles:, available_owners:,
                               available_systems:, available_types:)

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
        sort_url = ->(field, direction) { apis_path(q: { s: "#{field} #{direction}" }) }

        row.sortable_head(query:, field: "name", sort_url:) { "API" }
        row.sortable_head(query:, field: "system_id", sort_url:) { "System" }
        row.sortable_head(query:, field: "owner_id", sort_url:) { "Owner" }
        row.sortable_head(query:, field: "type", sort_url:) { "Type" }
        row.sortable_head(query:, field: "lifecycle", sort_url:) { "Lifecycle" }

        row.head(class: "relative") do
          span(class: "sr-only") { "View" }
        end
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @apis.each do |api|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if api.image_url.present?
                img(src: api.image_url, alt: "#{api.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(api.icon, class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { api.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { api.description }
              end
            end
          end

          row.cell do
            Link(href: system_path(api.system), class: "ps-0") { api.system.name } if api.system.present?
          end

          row.cell do
            Link(href: group_path(api.owner)) { api.owner.name } if api.owner.present?
          end

          row.cell do
            break unless api.type.present?

            if CatalogOptions.apis.key?(api.type)
              CatalogOptions.apis[api.type][:name]
            else
              api.type.capitalize
            end
          end

          row.cell do
            Components::Badge(variant: api.lifecycle) { api.lifecycle&.capitalize }
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: api_path(api), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
