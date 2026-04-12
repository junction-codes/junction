# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Edit view for domains.
      class Edit < Views::Base
        attr_reader :available_owners, :breadcrumbs, :can_destroy, :domain

        # Initializes the view.
        #
        # @param domain [Domain] The domain being modified.
        # @param available_owners [Array<Array>] Owner entity options with name
        #   and id attributes.
        # @param can_destroy [Boolean] Whether the domain can be destroyed.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(domain:, available_owners:, can_destroy:,
                       breadcrumbs: [])
          @domain = domain
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
            # Page header.
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") do
                t(".description", title: @domain.title)
              end
            end

            # Two-column layout for form and sidebar.
            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                DomainForm(domain:, available_owners:)
              end

              aside(class: "space-y-6") do
                DomainEditSidebar(domain:, can_destroy:)
              end
            end
          end
        end
      end
    end
  end
end
