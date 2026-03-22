# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Show view for components.
      class Show < Views::Base
        include PluginDispatchHelper

        attr_reader :breadcrumbs

        def initialize(component:, can_edit:, can_destroy:, breadcrumbs: [])
          @component = component
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              component_header
              component_stats
              component_tabs
            end
          end
        end

        private

        def component_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @component.image_url.present?
                img(src: @component.image_url, alt: "#{@component.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(@component.icon, class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @component.name }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @component.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @component.owner.present?
                    span do
                      render_view_link(@component.owner, class: "p-0 inline")
                    end
                  else
                    span { plain "NO OWNER" }
                  end
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Type:" }
                  span { plain @component.type }
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Repository:" }
                  span { Link(href: @component.repository_url, class: "p-0 text-blue-600 hover:underline dark:text-blue-400 inline") { @component.repository_url } }
                end if @component.repository_url.present?
              end

              div do
                break unless @component.system.present?

                if allowed_to?(:show?, @component.system)
                  Link(href: system_path(@component.system)) { "Part of the '#{@component.system.name}' System" }
                else
                  Link(variant: :disabled) { "Part of the '#{@component.system.name}' System" }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_component_path(@component)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit Component"
                end
              end
            end
          end
        end

        def component_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)

            render_plugin_ui_components(context: @component, slot: :overview_cards)
          end
        end

        def component_tabs
          Tabs do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") do
                icon("blocks", class: "pe-2")
                plain "Dependencies"
              end

              render_plugin_tab_triggers(@component, list)
            end

            tabs.content(value: "dependencies") do
              dependencies_section
            end

            render_plugin_tab_content(@component, tabs)
          end
        end

        def dependencies_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Dependencies" }
            Tabs(default_value: "dependencies") do |tabs|
              tabs.list do |list|
                list.trigger(value: "dependencies") { "Dependencies" }
                list.trigger(value: "dependents") { "Dependents" }
                list.trigger(value: "graph") { "Graph" }
              end

              tabs.content(value: "dependencies") do
                turbo_frame_tag "dependencies", src: dependencies_component_path(@component), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "dependents") do
                turbo_frame_tag "dependents", src: dependents_component_path(@component), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "graph") do
                dependency_graph
              end
            end
          end
        end

        def dependency_graph
          div do
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden p-5") do
              div(data_controller: "graph", data_graph_url_value: dependency_graph_component_path(@component)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end
      end
    end
  end
end
