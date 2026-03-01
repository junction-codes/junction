# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Edit view for APIs.
      class Edit < Views::Base
        attr_reader :api, :available_owners, :available_systems, :can_destroy

        # Initializes the view.
        #
        # @param api [Api] The API being modified.
        # @param available_owners [Array<Array>] Owner entity options with name and id
        #   attributes.
        # @param available_systems [Array<Array>] System entity options with name and
        #   id attributes.
        # @param can_destroy [Boolean] Whether the API can be destroyed.
        def initialize(api:, available_owners:, available_systems:, can_destroy:)
          @api = api
          @available_owners = available_owners
          @available_systems = available_systems
          @can_destroy = can_destroy
        end

        def view_template
          render Junction::Layouts::Application do
            template
          end
        end

        def template
          div(class: "p-6 space-y-6") do
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit API" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@api.name}' API." }
            end

            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                ApiForm(api:, available_owners:, available_systems:)
              end

              aside(class: "space-y-6") do
                ApiEditSidebar(api:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
