# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Renders the form for a new role.
      #
      # The same editor as {Edit}, with nothing selected and no rail cards for
      # reach or deletion.
      class New < Views::Base
        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param role [Junction::Role] The role being created.
        # @param available_permissions [Array<Junction::Permission>] Every
        #   permission that may be granted.
        # @param submitted [Array<String>] The permissions a rejected save
        #   sent, which are selected in place of an empty grid.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(role:, available_permissions:, submitted: nil,
                       breadcrumbs: [])
          @role = role
          @available_permissions = available_permissions
          @submitted = submitted
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            SettingsPage(title: t(".title"), description: t(".description")) do
              RoleForm(role: @role, available_permissions: @available_permissions,
                       submitted: @submitted)
            end
          end
        end
      end
    end
  end
end
