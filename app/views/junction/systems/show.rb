# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Show view for Systems.
      class Show < Views::Base
        attr_reader :breadcrumbs

        def initialize(system:, can_edit:, can_destroy:, breadcrumbs: [])
          @system = system
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              system_header
              system_stats
              entities_section
            end
          end
        end

        private

        def system_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @system.image_url.present?
                img(src: @system.image_url, alt: "#{@system.title} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("network", class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @system.title }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @system.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @system.owner.present?
                    span { render_view_link(@system.owner, class: "p-0 inline") }
                  else
                    span { plain "NO OWNER" }
                  end
                end
              end

              div do
                break unless @system.domain.present?

                if allowed_to?(:show?, @system.domain)
                  Link(href: domain_path(@system.domain)) { "Part of the '#{@system.domain.title}' Domain" }
                else
                  Link(variant: :disabled) { "Part of the '#{@system.domain.title}' Domain" }
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
            StatCard(title: "Total Components", value: @system.components.count, icon: "server")
            StatCard(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
          end
        end

        def entities_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") { "Entities" }
            Tabs(default: "apis") do |tabs|
              tabs.list do |list|
                list.trigger(value: "apis") { "APIs" }
                list.trigger(value: "components") { "Components" }
                list.trigger(value: "resources") { "Resources" }
              end

              tabs.content(value: "apis") do
                turbo_frame_tag "system_apis", src: apis_system_path(@system), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "components") do
                turbo_frame_tag "system_components", src: components_system_path(@system), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "resources") do
                turbo_frame_tag "system_resources", src: resources_system_path(@system), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end
            end
          end
        end
      end
    end
  end
end
