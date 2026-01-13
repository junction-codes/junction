# frozen_string_literal: true

# Creation view for APIs.
class Views::Apis::New < Views::Base
  attr_reader :api, :available_owners, :available_systems

  # Initializes the view.
  #
  # @param api [Api] The API being created.
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
    div(class: "p-6") do
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New API" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new API." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::ApiForm(api:, available_owners:, available_systems:)
      end
    end
  end
end
