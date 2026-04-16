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
                img(src: @component.image_url, alt: t(".logo_alt", name: @component.title),
                    class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(@component.icon, class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @component.title }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @component.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") do
                    "#{Junction::Component.human_attribute_name(:owner_id)}:"
                  end

                  if @component.owner.present?
                    span do
                      render_view_link(@component.owner, class: "p-0 inline")
                    end
                  else
                    span { plain t(".no_owner") }
                  end
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") do
                    "#{Junction::Component.human_attribute_name(:type)}:"
                  end

                  span { plain @component.type }
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") do
                    "#{Junction::Component.human_attribute_name(:repository_url)}:"
                  end

                  span { Link(href: @component.repository_url, class: "p-0 text-blue-600 hover:underline dark:text-blue-400 inline") { @component.repository_url } }
                end if @component.repository_url.present?
              end

              div do
                break unless @component.system.present?

                if allowed_to?(:show?, @component.system)
                  Link(href: junction_catalog_path(@component.system)) { t(".part_of_system", system_title: @component.system.title) }
                else
                  Link(variant: :disabled) { t(".part_of_system", system_title: @component.system.title) }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: junction_edit_catalog_path(@component)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain t(".edit")
                end
              end
            end
          end
        end

        def component_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: t(".stat_active_incidents"), value: "1", icon: "siren", status: :warning)

            render_plugin_ui_components(context: @component, slot: :overview_cards)
          end
        end

        def component_tabs
          Tabs do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") do
                icon("blocks", class: "pe-2")
                plain Junction::Dependency.model_name.human(count: 2)
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
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") do
              Junction::Dependency.model_name.human(count: 2)
            end

            Tabs(default: "dependencies") do |tabs|
              tabs.list do |list|
                list.trigger(value: "dependencies") { Junction::Dependency.model_name.human(count: 2) }
                list.trigger(value: "dependents") { t(".dependents") }
                list.trigger(value: "graph") { t(".graph") }
              end

              tabs.content(value: "dependencies") do
                turbo_frame_tag "dependencies", src: junction_dependencies_path(@component), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "dependents") do
                turbo_frame_tag "dependents", src: junction_dependents_path(@component), loading: :lazy do
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
              div(data_controller: "graph", data_graph_url_value: junction_dependency_graph_path(@component)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end
      end
    end
  end
end
