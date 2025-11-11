# frozen_string_literal: true

class Views::Components::Show < Views::Base
  include PluginDispatchHelper

  def initialize(component:, dependencies:, dependents:)
    @component = component
    @dependencies = dependencies
    @dependents = dependents
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6 space-y-8") do
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
                Link(href: group_path(@component.owner), class: "p-0 inline") { @component.owner.name }
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
          if @component.system.present?
            Link(href: system_path(@component.system), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
              "Part of the '#{@component.system.name}' System"
            end
          end
        end
      end

      # Right side: action buttons.
      div(class: "flex-shrink-0") do
        Link(variant: :primary, href: edit_component_path(@component)) do
          icon("pencil", class: "w-4 h-4 mr-2")
          plain "Edit Component"
        end
      end
    end
  end

  def component_stats
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
      render Components::StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)

      render_plugin_ui_components(context: @component, slot: :overview_cards)
    end
  end

  def component_tabs
    render Components::Tabs.new do |tabs|
      tabs.list do |list|
        list.trigger(value: "dependencies") do
          icon("blocks", class: "pe-2")
          plain "Dependencies"
        end

        list.trigger(value: "deployments") do
          icon("rocket", class: "pe-2")
          plain "Deployments"
        end

        render_plugin_tab_triggers(@component, list)
      end

      tabs.content(value: "dependencies") do
        dependencies_section
      end
      tabs.content(value: "deployments") do
        deployments_table
      end

      render_plugin_tab_content(@component, tabs)
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
            td(class: "px-6 py-4 whitespace-nowrap") { dependency.type }
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
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Component Name" }
          th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Type" }
          th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
        end
      end

      tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
        @dependents.each do |dependent|
          tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
            td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { dependent.name }
            td(class: "px-6 py-4 whitespace-nowrap") { dependent.type }
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
        div(data_controller: "graph", data_graph_url_value: dependency_graph_component_path(@component)) do
          div(data_graph_target: "container", class: "w-full h-60")
        end
      end
    end
  end

  def deployments_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Deployments" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Environment" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Platform" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Identifier" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @component.deployments.each do |deployment|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { deployment.environment }
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { deployment.platform }
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { deployment.location_identifier }
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: deployment_path(deployment), class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end
end
