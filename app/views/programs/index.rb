# frozen_string_literal: true

class Views::Programs::Index < Views::Base
  def initialize(programs:)
    @programs = programs
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        # Page header.
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Programs" }
          Link(variant: :primary, href: new_program_path) do
            "New Program"
          end
        end

        # Programs table.
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
        row.head do
          "Program Name"
        end
        row.head do
          "Status"
        end
        row.head(class: "relative") do
          span(class: "sr-only") { "View" }
        end
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @programs.each do |program|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if program.logo_url.present?
                img(src: program.logo_url, alt: "#{program.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("briefcase", class: "h-6 w-6 text-gray-500")
                end
              end

              # Program details.
              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { program.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { program.description }
              end
            end
          end

          row.cell do
            render Components::Badge.new(variant: program.status&.to_sym) { program.status&.capitalize }
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: program_path(program), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
