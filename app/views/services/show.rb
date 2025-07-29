# frozen_string_literal: true

class Views::Services::Show < Views::Base
  def initialize(service:)
    @service = service
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6 space-y-8") do
        service_header
        service_stats
        projects_table
        dependencies_section
      end
    end
  end

  private

  def service_header
    div(class: "flex justify-between items-start") do
      # Left side: logo, title, and description.
      div(class: "flex items-center space-x-6") do
        if @service.image_url.present?
          img(src: @service.image_url, alt: "#{@service.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
        else
          div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
            icon("server", class: "h-10 w-10 text-gray-500")
          end
        end

        div do
          h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @service.name }

          p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @service.description }
          div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
            span(class: "font-semibold mr-2") { "Owner:" }
            span { plain "NO OWNER" }
          end
        end

        div do
          if @service.program
            Link(href: program_path(@service.program), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
              "Part of the '#{@service.program.name}' Program"
            end
          end
        end
      end

      # Right side: action buttons.
      div(class: "flex-shrink-0") do
        Link(variant: :primary, href: edit_service_path(@service)) do
          icon("pencil", class: "w-4 h-4 mr-2")
          plain "Edit Service"
        end
      end
    end
  end

  def service_stats
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
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
            @service.projects.each do |project|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { project.name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Components::Badge.new(variant: project.status.to_sym) { project.status.capitalize }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: project_path(project), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end

  def dependencies_section
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Dependencies" }
        Tabs(default_value: "account") do
          TabsList do
            TabsTrigger(value: "dependencies") { "Dependencies" }
            TabsTrigger(value: "reverse") { "Reverse Dependencies" }
          end

          TabsContent(value: "dependencies", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              dependencies_table
          end

          TabsContent(value: "reverse", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
            dependents_table
          end
        end
    end
  end

  def dependencies_table
    table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
      thead(class: "bg-gray-50 dark:bg-gray-700") do
        tr do
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Service Name" }
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Status" }
          th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
        end
      end

      tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
        @service.dependencies.each do |service|
          tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
            td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { service.name }
            td(class: "px-6 py-4 whitespace-nowrap") do
              render Components::Badge.new(variant: service.status.to_sym) { service.status.capitalize }
            end
            td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
              a(href: service_path(service), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
            end
          end
        end
      end
    end
  end

  def dependents_table
    table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
      thead(class: "bg-gray-50 dark:bg-gray-700") do
        tr do
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Service Name" }
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Status" }
          th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
        end
      end

      tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
        @service.dependents.each do |service|
          tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
            td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { service.name }
            td(class: "px-6 py-4 whitespace-nowrap") do
              render Components::Badge.new(variant: service.status.to_sym) { service.status.capitalize }
            end
            td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
              a(href: service_path(service), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
            end
          end
        end
      end
    end
  end
end
