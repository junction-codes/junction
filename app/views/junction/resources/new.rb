# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Creation view for resources.
      class New < Views::Base
        attr_reader :available_owners, :available_systems, :breadcrumbs,
                     :resource

        # Initializes the view.
        #
        # @param resource [Resource] The resource being created.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with
        #   name and id attributes.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(resource:, available_owners:, available_systems:,
                       breadcrumbs: [])
          @resource = resource
          @available_owners = available_owners
          @available_systems = available_systems
          @breadcrumbs = breadcrumbs
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
              ResourceForm(resource:, available_owners:, available_systems:)
            end
          end
        end
      end
    end
  end
end
