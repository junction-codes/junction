# frozen_string_literal: true

# Creation view for resources.
class Views::Resources::New < Views::Base
  attr_reader :available_owners, :available_systems, :resource

  # Initializes the view.
  #
  # @param resource [Resource] The resource being created.
  # @param available_owners [Array<Array>] Owner entity options with name and
  #   id attributes.
  # @param available_systems [Array<Array>] System entity options with name and
  #  id attributes.W
  def initialize(resource:, available_owners:, available_systems:)
    @resource = resource
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
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Resource" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new rsource." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::ResourceForm(resource:, available_owners:, available_systems:)
      end
    end
  end
end
