# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Creation view for APIs.
      class New < Views::Base
        attr_reader :api, :available_owners, :available_systems, :breadcrumbs

        # Initializes the view.
        #
        # @param api [Api] The API being created.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param available_systems [Array<Array>] System entity options with name
        #   and id attributes.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(api:, available_owners:, available_systems:,
                       breadcrumbs: [])
          @api = api
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
              ApiForm(api:, available_owners:, available_systems:)
            end
          end
        end
      end
    end
  end
end
