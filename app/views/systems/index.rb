# frozen_string_literal: true

# Index view for Systems.
class Views::Systems::Index < Views::Base
  attr_reader :available_domains, :available_owners, :available_statuses,
              :query, :systems

  # Initializes the view.
  #
  # @param systems [ActiveRecord::Relation] Collection of systems to display.
  # @param query [Ransack::Search] Ransack query object for filtering and
  #   sorting.
  # @param available_domains [Array<Array>] Domain entity options with name and
  #   id attributes.
  # @param available_owners [Array<Array>] Owner entity options with name and id
  #   attributes.
  # @param available_statuses [Array<Array>] Status options as [label, value]
  #   pairs for filtering.
  def initialize(systems:, query:, available_domains:, available_owners:, available_statuses:)
    @systems = systems
    @query = query
    @available_domains = available_domains
    @available_owners = available_owners
    @available_statuses = available_statuses
  end

  def view_template
    render Layouts::Application do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Systems" }
          Link(variant: :primary, href: new_system_path) do
            "New System"
          end
        end

        Components::SystemFilters(query:, available_domains:, available_owners:,
                                  available_statuses:)

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
        sort_url = ->(field, direction) { systems_path(q: { s: "#{field} #{direction}" }) }

        row.sortable_head(query:, field: "name", sort_url:) { "System" }
        row.sortable_head(query:, field: "owner_id", sort_url:) { "Owner" }
        row.sortable_head(query:, field: "domain_id", sort_url:) { "Domain" }
        row.sortable_head(query:, field: "status", sort_url:) { "Status" }

        row.head(class: "relative") do
          span(class: "sr-only") { "View" }
        end
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @systems.each do |system|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if system.image_url.present?
                img(src: system.image_url, alt: "#{system.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("network", class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { system.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { system.description }
              end
            end
          end

          row.cell do
            Link(href: group_path(system.owner)) { system.owner.name } if system.owner.present?
          end

          row.cell do
            Link(href: domain_path(system.domain), class: "ps-0") { system.domain.name } if system.domain.present?
          end

          row.cell do
            Components::Badge(variant: system.status&.to_sym) { system.status&.capitalize }
          end


          row.cell(class: "text-right text-sm font-medium") do
            a(href: system_path(system), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
