# frozen_string_literal: true

class Views::Projects::Show < Views::Base
  def initialize(project:)
    @project = project
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6 space-y-8") do
        project_header
        project_stats
        services_table
      end
    end
  end

  private

  def project_header
    div(class: "flex justify-between items-start") do
      # Left side: logo, title, and description.
      div(class: "flex items-center space-x-6") do
        if @project.image_url.present?
          img(src: @project.image_url, alt: "#{@project.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
        else
          div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
            icon("kanban", class: "h-10 w-10 text-gray-500")
          end
        end

        div do
          h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @project.name }

          p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @project.description }
          div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
            span(class: "font-semibold mr-2") { "Owner:" }
            span { plain "NO OWNER" }
          end
        end

        div do
          if @project.program
            Link(href: program_path(@project.program), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
              "Part of the '#{@project.program.name}' Program"
            end
          end
        end
      end

      # Right side: action buttons.
      div(class: "flex-shrink-0") do
        Link(variant: :primary, href: edit_project_path(@project)) do
          icon("pencil", class: "w-4 h-4 mr-2")
          plain "Edit Project"
        end
      end
    end
  end

  def project_stats
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
      render Components::StatCard.new(title: "Total Services", value: 7, icon: "server")
      render Components::StatCard.new(title: "Monthly Cost", value: "$1,250", icon: "dollar-sign")
      render Components::StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
    end
  end

  def services_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Services" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Service Name" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Status" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @project.services.each do |service|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { service.name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Components::Badge.new(variant: service.status.to_sym) { service.status.capitalize }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: "/services/#{service.id}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end
end
