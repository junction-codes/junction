# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Show view for resources.
      class Show < Views::Base
        attr_reader :breadcrumbs

        def initialize(resource:, can_edit:, can_destroy:, breadcrumbs: [])
          @resource = resource
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
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
                img(src: @resource.image_url, alt: "#{@resource.title} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(@resource.icon, class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @resource.title }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @resource.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @resource.owner.present?
                    span do
                      render_view_link(@resource.owner, class: "p-0 inline")
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
                break unless @resource.system.present?

                if allowed_to?(:show?, @resource.system)
                  Link(href: system_path(@resource.system)) { "Part of the '#{@resource.system.title}' System" }
                else
                  Link(variant: :disabled) { "Part of the '#{@resource.system.title}' System" }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_resource_path(@resource)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit Resource"
                end
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
          Tabs do |tabs|
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
            Tabs(default: "dependencies") do |tabs|
              tabs.list do |list|
                list.trigger(value: "dependencies") { "Dependencies" }
                list.trigger(value: "dependents") { "Dependents" }
                list.trigger(value: "graph") { "Graph" }
              end

              tabs.content(value: "dependencies") do
                turbo_frame_tag "dependencies", src: resource_dependencies_path(@resource), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "dependents") do
                turbo_frame_tag "dependents", src: resource_dependents_path(@resource), loading: :lazy do
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
