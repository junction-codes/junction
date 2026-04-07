# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Edit view for a role.
      class Edit < Views::Base
        attr_reader :available_permissions, :breadcrumbs, :can_destroy, :role

        # Initialize a new view.
        #
        # @param role [Junction::Role] The role being edited.
        # @param available_permissions [Array<Junction::Permission>] Available
        #   permissions to select from.
        # @param can_destroy [Boolean] Whether the role can be destroyed.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(role:, available_permissions:, can_destroy:,
                       breadcrumbs: [])
          @role = role
          @available_permissions = available_permissions
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        private

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-6") do
              div do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t("views.roles.edit.title") }
                p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") do
                  plain t("views.roles.edit.description", name: @role.title)
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
