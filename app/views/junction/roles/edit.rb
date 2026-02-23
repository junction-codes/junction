# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Edit view for a role.
      class Edit < Views::Base
        attr_reader :available_permissions, :can_destroy, :role

        # Initialize a new view.
        #
        # @param role [Junction::Role] The role being edited.
        # @param available_permissions [Array<Junction::Permission>] Available
        #   permissions to select from.
        # @param can_destroy [Boolean] Whether the role can be destroyed.
        def initialize(role:, available_permissions:, can_destroy:)
          @role = role
          @available_permissions = available_permissions
          @can_destroy = can_destroy
        end

        def view_template
          render Layouts::Application do
            div(class: "p-6 space-y-6") do
              div do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t("views.roles.edit.title") }
                p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") do
                  plain t("views.roles.edit.description", name: @role.name)
                end
              end

              div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
                main(class: "lg:col-span-2") do
                  RoleForm(role:, available_permissions:)
                end

                aside(class: "space-y-6") do
                  RoleEditSidebar(role:, can_destroy:)
                end
              end
            end
          end
        end
      end
    end
  end
end
