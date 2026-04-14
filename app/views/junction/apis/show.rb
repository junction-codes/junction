# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Show view for APIs.
      class Show < Views::Base
        include PluginDispatchHelper

        attr_reader :breadcrumbs

        def initialize(api:, can_edit:, can_destroy:, breadcrumbs: [])
          @api = api
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              api_header
              api_stats
              api_tabs
            end
          end
        end

        private

        def api_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @api.image_url.present?
                img(src: @api.image_url, alt: t(".logo_alt", name: @api.title),
                    class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon(@api.icon, class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @api.title }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @api.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "#{Junction::Api.human_attribute_name(:owner_id)}:" }

                  if @api.owner.present?
                    span { render_view_link(@api.owner, class: "p-0 inline") }
                  else
                    span { plain t(".no_owner") }
                  end
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "#{Junction::Api.human_attribute_name(:type)}:" }
                  span { plain @api.type }
                end
              end

              div do
                break unless @api.system.present?

                if allowed_to?(:show?, @api.system)
                  Link(href: junction_catalog_path(@api.system)) { t(".part_of_system", system_title: @api.system.title) }
                else
                  Link(variant: :disabled) { t(".part_of_system", system_title: @api.system.title) }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: junction_edit_catalog_path(@api)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain t(".edit")
                end
              end
            end
          end
        end

        def api_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            # TODO: Remove placeholder.
            render StatCard.new(title: t(".stat_active_incidents"), value: "1", icon: "siren", status: :warning)

            render_plugin_ui_components(context: @api, slot: :overview_cards)
          end
        end

        def api_tabs
          Tabs do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") do
                icon("blocks", class: "pe-2")
                plain Junction::Dependency.model_name.human(count: 2)
              end

              list.trigger(value: "definition") do
                icon("file-text", class: "pe-2")
                plain Junction::Api.human_attribute_name(:definition)
              end

              render_plugin_tab_triggers(@api, list)
            end

            tabs.content(value: "dependencies") do
              dependencies_section
            end

            tabs.content(value: "definition") do
              definition_section
            end

            render_plugin_tab_content(@api, tabs)
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
                turbo_frame_tag "dependencies", src: junction_dependencies_path(@api), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "dependents") do
                turbo_frame_tag "dependents", src: junction_dependents_path(@api), loading: :lazy do
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
              div(data_controller: "graph", data_graph_url_value: junction_dependency_graph_path(@api)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end

        def definition_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") do
              Junction::Api.human_attribute_name(:definition)
            end

            Tabs(default_value: "raw") do |tabs|
              tabs.list do |list|
                list.trigger(value: "raw") { t(".raw") }
              end

             tabs.content(value: "raw", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                if @api.definition.present?
                  pre(class: "bg-gray-100 dark:bg-gray-900 p-4 rounded-lg overflow-x-auto") do
                    code(class: "language-yaml") do
                      plain @api.definition
                    end
                  end
                else
                  p(class: "text-gray-600 dark:text-gray-400") { t(".no_definition") }
                end
              end
            end
          end
        end
      end
    end
  end
end
