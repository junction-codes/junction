# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Edit view for Systems.
      class Edit < Views::Base
        attr_reader :available_domains, :available_owners, :breadcrumbs,
                    :can_destroy, :system

        # Initializes the view.
        #
        # @param system [System] The system being modified.
        # @param available_domains [Array<Array>] Domain entity options with
        #   name and id attributes.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param can_destroy [Boolean] Whether the system can be destroyed.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(system:, available_domains:, available_owners:,
                       can_destroy:, breadcrumbs: [])
          @system = system
          @available_domains = available_domains
          @available_owners = available_owners
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) { template }
        end

        private

        def template
          div(class: "px-6 py-3 space-y-6") do
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit System" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@system.title}' system." }
            end

            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                SystemForm(system:, available_domains:, available_owners:)
              end

              aside(class: "space-y-6") do
                SystemEditSidebar(system:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
