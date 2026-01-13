# frozen_string_literal: true

# Edit view for APIs.
class Views::Apis::Edit < Views::Base
  attr_reader :api, :available_owners, :available_systems

  # Initializes the view.
  #
  # @param api [Api] The API being modified.
  # @param available_owners [Array<Array>] Owner entity options with name and id
  #   attributes.
  # @param available_systems [Array<Array>] System entity options with name and
  #   id attributes.
  def initialize(api:, available_owners:, available_systems:)
    @api = api
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
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit API" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@api.name}' API." }
      end

      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          Components::ApiForm(api:, available_owners:, available_systems:)
        end

        aside(class: "space-y-6") do
          Components::ApiEditSidebar(api:)
        end
      end
    end
  end
end
