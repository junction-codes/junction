# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Edit view for groups.
      class Edit < Views::Base
        attr_reader :available_parents, :can_destroy, :group

        # Initializes the view.
        #
        # @param group [Group] The group being modified.
        # @param available_parents [Array<Array>] Parent entity options with
        #   name and id attributes.
        # @param can_destroy [Boolean] Whether the group can be destroyed.
        def initialize(group:, available_parents:, can_destroy:)
          @group = group
          @available_parents = available_parents
          @can_destroy = can_destroy
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
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Group" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@group.name}' group." }
            end

            # Two-column layout for form and sidebar.
            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                GroupForm(group:, available_parents:)
              end

              aside(class: "space-y-6") do
                GroupEditSidebar(group:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
