# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Edit view for components.
      class Edit < Views::Base
        attr_reader :available_owners, :available_systems, :component

        # Initializes the view.
        #
        # @param component [Component] The component being modified.
        # @param available_owners [Array<Array>] Owner entity options with name and id
        #   attributes.
        # @param available_systems [Array<Array>] System entity options with name and
        #   id attributes.
        def initialize(component:, available_owners:, available_systems:)
          @component = component
          @available_owners = available_owners
          @available_systems = available_systems
        end

        def view_template
          render Junction::Layouts::Application do
            template
          end
        end

        def template
          div(class: "p-6 space-y-6") do
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Component" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@component.name}' component." }
            end

            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                ComponentForm(component:, available_owners:, available_systems:)
              end

              aside(class: "space-y-6") do
                ComponentEditSidebar(component:)
              end
            end
          end
        end
      end
    end
  end
end
