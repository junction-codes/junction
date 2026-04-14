# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Show view for Users.
      class Show < Views::Base
        attr_reader :breadcrumbs

        def initialize(user:, can_edit:, can_destroy:, breadcrumbs: [])
          @user = user
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              user_header
              user_stats
            end
          end
        end

        private

        def user_header
          div(class: "flex justify-between items-start") do
            # Left side: logo, title, and description.
            div(class: "flex items-center space-x-6") do
              if @user.image_url.present?
                img(src: @user.image_url, alt: t(".logo_alt", name: @user.title), class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
              else
                div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("user-round", class: "h-10 w-10 text-gray-500")
                end
              end

              div do
                h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @user.title }
                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @user.pronouns }

                p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") do
                  Link(href: "mailto:#{@user.email_address}", class: "p-0 inline") { @user.email_address }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: junction_edit_catalog_path(@user)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain t(".edit")
                end
              end
            end
          end
        end

        def user_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            StatCard(title: t(".stat_total_groups"), value: @user.group_memberships.count, icon: "users-round")
            StatCard(title: t(".stat_total_systems"), value: @user.systems.count, icon: "network")
            StatCard(title: t(".stat_total_components"), value: @user.components.count, icon: "server")

            render_plugin_ui_components(context: @user, slot: :user_profile_cards)
          end
        end
      end
    end
  end
end
