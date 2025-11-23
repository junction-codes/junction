# frozen_string_literal: true

class Views::Systems::Index < Views::Base
  def initialize(systems:)
    @systems = systems
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Systems" }
          Link(variant: :primary, href: new_system_path) do
            "New System"
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
        row.head { "System" }
        row.head { "Owner" }
        row.head { "Domain" }
        row.head { "Status" }
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
            render Components::Badge.new(variant: system.status&.to_sym) { system.status&.capitalize }
          end


          row.cell(class: "text-right text-sm font-medium") do
            a(href: system_path(system), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
