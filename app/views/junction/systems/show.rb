# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Show view for Systems.
      class Show < Views::Base
        def initialize(system:, can_edit:, can_destroy:)
          @system = system
          @can_edit = can_edit
          @can_destroy = can_destroy
        end

        def view_template
          render Junction::Layouts::Application.new do
            div(class: "p-6 space-y-8") do
              system_header
              system_stats
              dependencies_section
            end
          end
        end

        private

        def dependency_graph
          div do
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden p-5") do
              div(data_controller: "graph", data_graph_url_value: dependency_graph_system_path(@system)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end

        def system_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @system.image_url.present?
                img(src: @system.image_url, alt: "#{@system.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("network", class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @system.name }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @system.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @system.owner.present?
                    span do
                      Link(href: group_path(@system.owner), class: "p-0 inline") { @system.owner.name }
                    end
                  else
                    span { plain "NO OWNER" }
                  end
                end
              end

              div do
                if @system.domain
                  Link(href: domain_path(@system.domain), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
                    "Part of the '#{@system.domain.name}' Domain"
                  end
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_system_path(@system)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit System"
                end
              end
            end
          end
        end

        def system_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: "Total Components", value: @system.components.count, icon: "server")
            render StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
          end
        end

        def dependencies_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Dependencies" }
            Tabs(default_value: "account") do
              TabsList do
                TabsTrigger(value: "components") { "Components" }
                TabsTrigger(value: "graph") { "Graph" }
              end

              TabsContent(value: "components", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                components_table
              end

              TabsContent(value: "graph", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                dependency_graph
              end
            end
          end
        end

        def components_table
          table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
            thead(class: "bg-gray-50 dark:bg-gray-700") do
              tr do
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Component Name" }
                th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Lifecycle" }
                th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
              end
            end

            tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
              @system.components.each do |component|
                tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                  td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { component.name }
                  td(class: "px-6 py-4 whitespace-nowrap") do
                    render Badge.new(variant: component.lifecycle&.to_sym) { component.lifecycle&.capitalize }
                  end
                  td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                    a(href: "/components/#{component.id}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
