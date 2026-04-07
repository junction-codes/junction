# frozen_string_literal: true

module Junction
  module Views
    module Domains
      class Show < Views::Base
        attr_reader :breadcrumbs

        def initialize(domain:, can_edit:, can_destroy:, breadcrumbs: [])
          @domain = domain
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              domain_header
              domain_stats
              domain_tabs
            end
          end
        end

        private

        def domain_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @domain.image_url.present?
                img(src: @domain.image_url, alt: "#{@domain.title} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("briefcase", class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @domain.title }
                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @domain.description }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @domain.owner.present?
                    span do
                      render_view_link(@domain.owner, class: "p-0 inline")
                    end
                  else
                    span { plain "NO OWNER" }
                  end
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_domain_path(@domain)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit Domain"
                end
              end
            end
          end
        end

        def domain_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: "Total Systems", value: @domain.systems.count, icon: "network")
            render StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
          end
        end

        def domain_tabs
          Tabs do |tabs|
            tabs.list do |list|
              list.trigger(value: "systems") do
                icon("network", class: "pe-2")
                plain "Systems"
              end
            end

            tabs.content(value: "systems") do
              turbo_frame_tag "domain_systems", src: systems_domain_path(@domain), loading: :lazy do
                div(class: "p-4") { Skeleton(class: "h-20") }
              end
            end
          end
        end
      end
    end
  end
end
