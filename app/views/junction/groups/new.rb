# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Creation view for groups.
      class New < Views::Base
        attr_reader :available_parents, :breadcrumbs, :group

        # Initializes the view.
        #
        # @param group [Group] The group being created.
        # @param available_parents [Array<Array>] Parent entity options with
        #   name and id attributes.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(group:, available_parents:, breadcrumbs: [])
          @group = group
          @available_parents = available_parents
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
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Group" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new group." }
            end

            main(class: "mt-6 max-w-2xl mx-auto") do
              GroupForm(group:, available_parents:)
            end
          end
        end
      end
    end
  end
end
