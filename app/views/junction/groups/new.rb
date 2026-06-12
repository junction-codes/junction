# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Creation view for groups.
      class New < Views::Base
        attr_reader :available_parents, :breadcrumbs, :group, :parent_editable,
                    :type_options

        # Initializes the view.
        #
        # @param group [Group] The group being created.
        # @param available_parents [ActiveRecord::Relation] Parent options.
        # @param parent_editable [Boolean] Whether the parent field should be
        #   editable.
        # @param type_options [Hash] Options for the group type field.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(group:, available_parents:, type_options:,
                       breadcrumbs: [], parent_editable: true)
          @available_parents = available_parents
          @breadcrumbs = breadcrumbs
          @group = group
          @parent_editable = parent_editable
          @type_options = type_options
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
              GroupForm(
                group:,
                available_parents:,
                parent_editable:,
                type_options:
              )
            end
          end
        end
      end
    end
  end
end
