# frozen_string_literal: true

class Views::Programs::Show < Views::Base
  def initialize(program:)
    @program = program
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6 space-y-8") do
        program_header
        program_stats
        projects_table
        services_table
      end
    end
  end

  private

  def program_header
    div(class: "flex justify-between items-start") do
      # Left side: logo, title, and description.
      div(class: "flex items-center space-x-6") do
        if @program.logo_url.present?
          img(src: @program.logo_url, alt: "#{@program.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
        else
          div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
            icon("briefcase", class: "h-10 w-10 text-gray-500")
          end
        end

        div do
          h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @program.name }
          p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @program.description }
          div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
            span(class: "font-semibold mr-2") { "Owner:" }
            span { plain "NO OWNER" }
          end
        end
      end

      # Right side: action buttons.
      div(class: "flex-shrink-0") do
        a(href: edit_program_path(@program), class: "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background bg-blue-600 text-white hover:bg-blue-700 h-10 py-2 px-4") do
          icon("pencil", class: "w-4 h-4 mr-2")
          plain "Edit Program"
        end
      end
    end
  end

  def program_stats
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
      render Components::StatCard.new(title: "Total Projects", value: 2, icon: "kanban")
      render Components::StatCard.new(title: "Total Services", value: 7, icon: "server")
      render Components::StatCard.new(title: "Monthly Cost", value: "$1,250", icon: "dollar-sign")
      render Components::StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
    end
  end

  def projects_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Projects" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Project Name" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Status" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @program.projects.each do |project|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { project.name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Components::Badge.new(variant: project.status.to_sym) { project.status.capitalize }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: "/projects/#{project.id}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
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
            @program.services.each do |service|
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
