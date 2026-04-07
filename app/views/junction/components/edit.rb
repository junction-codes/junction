# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Edit view for components.
      class Edit < Views::Base
        attr_reader :available_owners, :available_systems, :breadcrumbs,
                     :can_destroy, :component

        # Initializes the view.
        #
        # @param component [Component] The component being modified.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with
        #   name and id attributes.
        # @param can_destroy [Boolean] Whether the component can be destroyed.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(component:, available_owners:, available_systems:,
                       can_destroy:, breadcrumbs: [])
          @component = component
          @available_owners = available_owners
          @available_systems = available_systems
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
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Component" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@component.title}' component." }
            end

            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                ComponentForm(component:, available_owners:, available_systems:)
              end

              aside(class: "space-y-6") do
                ComponentEditSidebar(component:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
