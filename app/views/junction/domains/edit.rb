# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Edit view for domains.
      class Edit < Views::Base
        attr_reader :available_owners, :domain

        # Initializes the view.
        #
        # @param domain [Domain] The domain being modified.
        # @param available_owners [Array<Array>] Owner entity options with name and id
        #   attributes.
        def initialize(domain:, available_owners:)
          @domain = domain
          @available_owners = available_owners
        end

        def view_template
          render Junction::Layouts::Application do
            template
          end
        end

        def template
          div(class: "p-6 space-y-6") do
            # Page header.
            div do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Domain" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@domain.name}' domain." }
            end

            # Two-column layout for form and sidebar.
            div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
              main(class: "lg:col-span-2") do
                ::Components::DomainForm(domain:, available_owners:)
              end

              aside(class: "space-y-6") do
                ::Components::DomainEditSidebar(domain:)
              end
            end
          end
        end
      end
    end
  end
end
