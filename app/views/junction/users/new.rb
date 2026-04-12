# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Creation view for users.
      class New < Views::Base
        attr_reader :breadcrumbs, :user

        # Initializes the view.
        #
        # @param user [User] The user being created.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(user:, breadcrumbs: [])
          @user = user
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) { template }
        end

        private

        def template
          div(class: "px-6 py-3") do
            # Page header.
            div(class: "max-w-2xl mx-auto") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { t(".description") }
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
