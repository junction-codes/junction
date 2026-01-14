# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Show view for resources.
      class Show < Views::Base
        def initialize(resource:, dependencies:, dependents:)
          @resource = resource
          @dependencies = dependencies
          @dependents = dependents
        end

        def view_template
          render Junction::Layouts::Application.new do
            div(class: "p-6 space-y-8") do
              resource_header
              resource_stats
              resource_tabs
            end
          end
        end

        private

        def resource_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @resource.image_url.present?
                img(src: @resource.image_url, alt: "#{@resource.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(@resource.icon, class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @resource.name }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @resource.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @resource.owner.present?
                    span do
                      Link(href: group_path(@resource.owner), class: "p-0 inline") { @resource.owner.name }
                    end
                  else
                    span { plain "NO OWNER" }
                  end
                end
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Type:" }
                  span { plain @resource.type }
                end
              end

              div do
                if @resource.system.present?
                  Link(href: system_path(@resource.system), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
                    "Part of the '#{@resource.system.name}' System"
                  end
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              Link(variant: :primary, href: edit_resource_path(@resource)) do
                icon("pencil", class: "w-4 h-4 mr-2")
                plain "Edit Resource"
              end
            end
          end
        end

        def resource_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render_plugin_ui_components(context: @resource, slot: :overview_cards)
          end
        end

        def resource_tabs
          render ::Components::Tabs.new do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") do
                icon("blocks", class: "pe-2")
                plain "Dependencies"
              end

              render_plugin_tab_triggers(@resource, list)
            end

            tabs.content(value: "dependencies") do
              dependencies_section
            end

            render_plugin_tab_content(@resource, tabs)
          end
        end

        def dependencies_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Dependencies" }
              Tabs(default_value: "dependencies") do
                TabsList do
                  TabsTrigger(value: "dependencies") { "Dependencies" }
                  TabsTrigger(value: "dependents") { "Dependents" }
                  TabsTrigger(value: "graph") { "Graph" }
                end

                TabsContent(value: "dependencies", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                    dependencies_table
                end

                TabsContent(value: "dependents", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                  dependents_table
                end

                TabsContent(value: "graph", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                  dependency_graph
                end
              end
          end
        end

        def dependencies_table
          table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
            thead(class: "bg-gray-50 dark:bg-gray-700") do
              tr do
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Name" }
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Type" }
                th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
              end
            end

            tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
              @dependencies.each do |dependency|
                tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                  td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { dependency.name }
                  td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { dependency.type }
                  td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                    a(href: url_for(dependency), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
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
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Name" }
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Type" }
                th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
              end
            end

            tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
              @dependents.each do |dependent|
                tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                  td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { dependent.name }
                  td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { dependent.type }
                  td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                    a(href: url_for(dependent), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                  end
                end
              end
            end
          end
        end

        def dependency_graph
          div do
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden p-5") do
              div(data_controller: "graph", data_graph_url_value: dependency_graph_resource_path(@resource)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end
      end
    end
  end
end
