# frozen_string_literal: true

class Views::Projects::Index < Views::Base
  def initialize(projects:)
    @projects = projects
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Projects" }
          Link(variant: :primary, href: new_project_path) do
            "New Project"
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
        row.head { "Project Name" }
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
      @projects.each do |project|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if project.image_url.present?
                img(src: project.image_url, alt: "#{project.name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("kanban", class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") { project.name }
                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { project.description }
              end
            end
          end

          row.cell do
            if project.program
              Link(href: program_path(project.program), class: 'ps-0') do
                project.program.name
              end
            end
          end

          row.cell do
            render Components::Badge.new(variant: project.status&.to_sym) { project.status&.capitalize }
          end

          row.cell(class: "text-right text-sm font-medium") do
            a(href: project_path(project), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
          end
        end
      end
    end
  end
end
