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
        def initialize(role:)
          @role = role
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
                  unless @role.system?
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
