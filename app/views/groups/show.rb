# frozen_string_literal: true

class Views::Groups::Show < Views::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    render Layouts::Application.new do
      div(class: "p-6 space-y-8") do
        group_header
        group_stats
        members_table
      end
    end
  end

  private

  def group_header
    div(class: "flex justify-between items-start") do
      # Left side: logo, title, and description.
      div(class: "flex items-center space-x-6") do
        if @group.image_url.present?
          img(src: @group.image_url, alt: "#{@group.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
        else
          div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
            icon(@group.icon, class: "h-10 w-10 text-gray-500")
          end
        end

        div do
          h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @group.name }
          p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @group.description }

          p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") do
            Link(href: "mailto:#{@group.email}", class: "p-0 inline") { @group.email }
          end if @group.email.present?
        end

        div do
          if @group.parent
            Link(href: group_path(@group.parent), class: "text-sm text-blue-600 hover:underline dark:text-blue-400") do
              "Child of the '#{@group.parent.name}' Group"
            end
          end
        end
      end

      # Right side: action buttons.
      div(class: "flex-shrink-0") do
        Link(variant: :primary, href: edit_group_path(@group)) do
          icon("pencil", class: "w-4 h-4 mr-2")
          plain "Edit Group"
        end
      end
    end
  end

  def group_stats
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
      render Components::StatCard.new(title: "Total Systems", value: 1, icon: "network")
      render Components::StatCard.new(title: "Total Components", value: 2, icon: "server")
    end
  end

  def systems_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Systems" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "System Name" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Status" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @group.systems.each do |system|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { system.name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Components::Badge.new(variant: system.status.to_sym) { system.status.capitalize }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: "#{system_path(system)}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end

  def components_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Components" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Component Name" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Lifecycle" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @group.components.each do |component|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { component.name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Components::Badge.new(variant: component.lifecycle&.to_sym) { component.lifecycle&.capitalize }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: "#{component_path(component)}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end

  def members_table
    div do
      h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Members" }
      div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
        table(class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700") do
          thead(class: "bg-gray-50 dark:bg-gray-700") do
            tr do
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Name" }
              th(scope: "col", class: "px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider") { "Email" }
              th(scope: "col", class: "relative px-6 py-3") { span(class: "sr-only") { "View" } }
            end
          end

          tbody(class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700") do
            @group.members.each do |user|
              tr(class: "hover:bg-gray-50 dark:hover:bg-gray-700/50") do
                td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white") { user.display_name }
                td(class: "px-6 py-4 whitespace-nowrap") do
                  render Link(href: "mailto:#{user.email_address}") { user.email_address }
                end
                td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                  a(href: "#{user_path(user)}", class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
                end
              end
            end
          end
        end
      end
    end
  end
end
