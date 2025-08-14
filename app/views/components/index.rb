# frozen_string_literal: true

class Views::Components::Index < Views::Base
  def initialize(components:)
    @components = components
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Components" }
          Link(variant: :primary, href: new_component_path) do
            "New Component"
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
        row.head { "Component Name" }
        row.head { "Domain" }
        row.head { "Lifecycle" }
        row.head(class: "relative") do
          span(class: "sr-only") { "View" }
        end
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @components.each do |component|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if component.image_url.present?
                img(src: component.image_url, alt: "#{component.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(component.icon, class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { component.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { component.description }
              end
            end
          end

          row.cell do
            if component.domain
              Link(href: domain_path(component.domain), class: 'ps-0') do
                component.domain.name
              end
            end
          end

          row.cell do
            render Components::Badge.new(variant: component.lifecycle&.to_sym) { component.lifecycle&.capitalize }
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: component_path(component), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
