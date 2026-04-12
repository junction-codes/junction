# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Edit view for users.
      class Edit < Views::Base
        attr_reader :breadcrumbs, :can_destroy, :user

        # Initializes the view.
        #
        # @param user [User] The user being modified.
        # @param can_destroy [Boolean] Whether the user can be destroyed.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(user:, can_destroy:, breadcrumbs: [])
          @user = user
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) { template }
        end

        private

        def template
          div(class: "px-6 py-3 space-y-6") do
            # Page header.
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") do
                t(".description", title: @user.title)
              end
            end

            # Two-column layout for form and sidebar.
            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                UserForm(user:)
              end

              aside(class: "space-y-6") do
                UserEditSidebar(user:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
