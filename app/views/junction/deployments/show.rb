# frozen_string_literal: true

module Junction
  module Views
    module Deployments
      # Show view for deployments.
      class Show < Views::Base
        def initialize(deployment:, can_edit:, can_destroy:)
          @deployment = deployment
          @can_edit = can_edit
          @can_destroy = can_destroy
        end

        def view_template
          render Junction::Layouts::Application.new do
            div(class: "p-6 space-y-8") do
              deployment_header
              deployment_stats
            end
          end
        end

        private

        def deployment_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @deployment.component.image_url.present?
                img(src: @deployment.component.image_url, alt: "#{@deployment.component.name} logo", class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("rocket", class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @deployment.component.name }
                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Owner:" }

                  if @deployment.component.owner.present?
                    span do
                      render_view_link(@deployment.component.owner, class: "p-0 inline")
                    end
                  else
                    span { plain "NO OWNER" }
                  end
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Environment:" }
                  span { @deployment.environment }
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Platform:" }
                  span { @deployment.platform }
                end

                div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
                  span(class: "font-semibold mr-2") { "Identifier:" }
                  span { @deployment.location_identifier }
                end
              end

              div do
                break unless @deployment.component.present?

                if allowed_to?(:show?, @deployment.component)
                  Link(href: component_path(@deployment.component)) { "A deployment of the '#{@deployment.component.name}' Component" }
                else
                  Link(variant: :disabled) { "A deployment of the '#{@deployment.component.name}' Component" }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_deployment_path(@deployment)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit Deployment"
                end
              end
            end
          end
        end

        def deployment_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: "Active Incidents", value: "1", icon: "siren", status: :warning)
          end
        end
      end
    end
  end
end
