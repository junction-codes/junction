# frozen_string_literal: true

# Creation view for components.
class Views::Components::New < Views::Base
  attr_reader :available_owners, :available_systems, :component

  # Initializes the view.
  #
  # @param component [Component] The component being created.
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
    render Layouts::Application do
      template
    end
  end

  def template
    div(class: "p-6") do
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Component" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new component." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::ComponentForm(component:, available_owners:, available_systems:)
      end
    end
  end
end
