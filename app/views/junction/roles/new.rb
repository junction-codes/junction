# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Creation view for roles.
      class New < Views::Base
        attr_reader :role, :available_permissions

        # Initialize a new view.
        #
        # @param role [Junction::Role] The role being created.
        # @param available_permissions [Array<Junction::Permission>] Available
        #   permissions to select from.
        def initialize(role:, available_permissions:)
          @role = role
          @available_permissions = available_permissions
        end

        def view_template
          render Layouts::Application do
            div(class: "p-6") do
              div(class: "max-w-2xl mx-auto") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t("views.roles.new.title") }
                p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { t("views.roles.new.description") }
              end

              main(class: "mt-6 max-w-2xl mx-auto") do
                render RoleForm.new(role:, available_permissions:)
              end
            end
          end
        end
      end
    end
  end
end
