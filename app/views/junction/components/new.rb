# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Creation view for components.
      class New < Views::Base
        attr_reader :available_owners, :available_systems, :breadcrumbs,
                     :component, :lifecycle_options, :type_options

        # Initializes the view.
        #
        # @param component [Component] The component being created.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with
        #   name and id attributes.
        # @param lifecycle_options [Hash] Options for the lifecycle field.
        # @param type_options [Hash] Options for the component type field.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(component:, available_owners:, available_systems:,
                       lifecycle_options:, type_options:, breadcrumbs: [])
          @component = component
          @available_owners = available_owners
          @available_systems = available_systems
          @breadcrumbs = breadcrumbs
          @lifecycle_options = lifecycle_options
          @type_options = type_options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) { template }
        end

        private

        def template
          div(class: "px-6 py-3") do
            div(class: "max-w-2xl mx-auto") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { t(".description") }
            end

            main(class: "mt-6 max-w-2xl mx-auto") do
              ComponentForm(
                component:,
                available_owners:,
                available_systems:,
                lifecycle_options:,
                type_options:
              )
            end
          end
        end
      end
    end
  end
end
