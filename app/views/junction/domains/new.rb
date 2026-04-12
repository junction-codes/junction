# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Creation view for domains.
      class New < Views::Base
        attr_reader :available_owners, :breadcrumbs, :domain

        # Initializes the view.
        #
        # @param domain [Domain] The domain being created.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(domain:, available_owners:, breadcrumbs: [])
          @domain = domain
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
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { t(".description") }
            end

            main(class: "mt-6 max-w-2xl mx-auto") do
              DomainForm(domain:, available_owners:)
            end
          end
        end
      end
    end
  end
end
