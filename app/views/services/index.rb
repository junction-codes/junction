# frozen_string_literal: true

class Views::Services::Index < Views::Base
  def initialize(services:)
    @services = services
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Services" }
          Link(variant: :primary, href: new_service_path) do
            "New Service"
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
        row.head { "Service Name" }
        row.head { "Program" }
        row.head { "Status" }
        row.head(class: "relative") do
          span(class: "sr-only") { "View" }
        end
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @services.each do |service|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if service.image_url.present?
                img(src: service.image_url, alt: "#{service.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("kanban", class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { service.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { service.description }
              end
            end
          end

          row.cell do
            if service.program
              Link(href: program_path(service.program), class: 'ps-0') do
                service.program.name
              end
            end
          end

          row.cell do
            render Components::Badge.new(variant: service.status&.to_sym) { service.status&.capitalize }
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: service_path(service), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
