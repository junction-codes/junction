# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Show view for groups.
      class Show < Views::Base
        attr_reader :breadcrumbs

        # Initialize the view.
        #
        # @param group [Junction::Group] Group to display.
        # @param can_edit [Boolean] Whether the user can edit the group.
        # @param can_destroy [Boolean] Whether the user can destroy the group.
        # @param can_view_members [Boolean] Whether the user can view the
        #   group's members.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(group:, can_edit:, can_destroy:, can_view_members: false,
                       breadcrumbs: [])
          @group = group
          @can_edit = can_edit
          @can_destroy = can_destroy
          @can_view_members = can_view_members
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              group_header
              group_stats
              group_tabs
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
                break unless @group.parent.present?

                if allowed_to?(:show?, @group.parent)
                  Link(href: group_path(@group.parent)) { "Child of the '#{@group.parent.name}' Group" }
                else
                  Link(variant: :disabled) { "Child of the '#{@group.parent.name}' Group" }
                end
              end
            end

            # Right side: action buttons.
            div(class: "flex-shrink-0") do
              if @can_edit
                Link(variant: :primary, href: edit_group_path(@group)) do
                  icon("pencil", class: "w-4 h-4 mr-2")
                  plain "Edit Group"
                end
              end
            end
          end
        end

        def group_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            render StatCard.new(title: "Total Systems", value: @group.systems.count, icon: "network")
            render StatCard.new(title: "Total Components", value: @group.components.count, icon: "server")

            render_plugin_ui_components(context: @group, slot: :group_profile_cards)
          end
        end

        def group_tabs
          render Tabs.new do |tabs|
            tabs.list do |list|
              if @can_view_members
                list.trigger(value: "members") do
                  icon("blocks", class: "pe-2")
                  plain "Members"
                end
              end

              render_plugin_tab_triggers(@group, list)
            end

            if @can_view_members
              tabs.content(value: "members") do
                turbo_frame_tag "group_members", src: group_members_path(@group), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end
            end

            render_plugin_tab_content(@group, tabs)
          end
        end
      end
    end
  end
end
