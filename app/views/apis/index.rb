# frozen_string_literal: true

class Views::Apis::Index < Views::Base
  def initialize(apis:)
    @apis = apis
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "APIs" }
          Link(variant: :primary, href: new_api_path) do
            "New API"
          end
        end

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
        row.head { "API Name" }
        row.head { "System" }
        row.head { "Lifecycle" }
        row.head { "Owner" }
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
            if api.system.present?
              Link(href: system_path(api.system), class: "ps-0") do
                api.system.name
              end
            end
          end

          row.cell do
            render Components::Badge.new(variant: api.lifecycle) { api.lifecycle&.capitalize }
          end

          row.cell do
            if api.owner.present?
              render Link(href: group_path(api.owner)) { api.owner.name }
            end
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: api_path(api), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
