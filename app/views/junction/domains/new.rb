# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Creation view for domains.
      class New < Views::Base
        attr_reader :available_owners, :domain

        # Initializes the view.
        #
        # @param domain [Domain] The domain being created.
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
          div(class: "p-6") do
            div(class: "max-w-2xl mx-auto") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Domain" }
              p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new domain." }
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
