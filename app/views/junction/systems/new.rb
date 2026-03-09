# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Creation view for Systems.
      class New < Views::Base
        attr_reader :available_domains, :available_owners, :breadcrumbs, :system

        # Initializes the view.
        #
        # @param system [System] The system being created.
        # @param available_domains [Array<Array>] Domain entity options with
        #   name and id attributes.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(system:, available_domains:, available_owners:,
                       breadcrumbs: [])
          @system = system
          @available_domains = available_domains
          @available_owners = available_owners
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) { template }
        end

        private

        def template
          div(class: "px-6 py-3") do
            div(class: "max-w-2xl mx-auto") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New System" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new system." }
            end

            main(class: "mt-6 max-w-2xl mx-auto") do
              SystemForm(system:, available_domains:, available_owners:)
            end
          end
        end
      end
    end
  end
end
