# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Show view for a role.
      #
      # @todo Display all groups and users with this role.
      class Show < Views::Base
        # Initialize a new view.
        #
        # @param role [Junction::Role] The role to display.
        # @param can_edit [Boolean] Whether the user can edit the role.
        # @param can_destroy [Boolean] Whether the user can destroy the role.
        def initialize(role:, can_edit:, can_destroy:)
          @role = role
          @can_edit = can_edit
          @can_destroy = can_destroy
        end

        def view_template
          render Junction::Layouts::Application do
            div(class: "p-6 space-y-6") do
              div(class: "flex justify-between items-start") do
                div do
                  h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @role.name }

                  p(class: "mt-1 text-md text-gray-600 dark:text-gray-400") { @role.description }
                end

                div(class: "flex gap-2") do
                  if @can_edit && !@role.system?
                    Link(variant: :primary, href: edit_role_path(@role)) { t("views.roles.show.edit") }
                  end
                end
              end

              unless @role.system?
                div(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-6") do
                  h3(class: "text-lg font-semibold text-gray-900 dark:text-white mb-4") do
                    plain t("views.roles.show.permissions")
                    plain " (#{@role.role_permissions.count})"
                  end

                  ul(class: "list-disc list-inside space-y-1 text-sm text-gray-600 dark:text-gray-400") do
                    @role.permission_strings.each do |permission|
                      li { permission }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
