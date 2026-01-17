# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Creation view for users.
      class New < Views::Base
        attr_reader :user

        # Initializes the view.
        #
        # @param user [User] The user being created.
        def initialize(user:)
          @user = user
        end

        def view_template
          render Junction::Layouts::Application do
            template
          end
        end

        def template
          div(class: "p-6") do
            # Page header.
            div(class: "max-w-2xl mx-auto") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New User" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new user." }
            end

            main(class: "mt-6 max-w-2xl mx-auto") do
              UserForm(user:)
            end
          end
        end
      end
    end
  end
end
