# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Edit view for users.
      class Edit < Views::Base
        attr_reader :user

        # Initializes the view.
        #
        # @param user [User] The user being modified.
        def initialize(user:)
          @user = user
        end

        def view_template
          render Junction::Layouts::Application do
            template
          end
        end

        def template
          div(class: "p-6 space-y-6") do
            # Page header.
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit User" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for #{@user.display_name}." }
            end

            # Two-column layout for form and sidebar.
            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                ::Components::UserForm(user:)
              end

              aside(class: "space-y-6") do
                ::Components::UserEditSidebar(user:)
              end
            end
          end
        end
      end
    end
  end
end
