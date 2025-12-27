# frozen_string_literal: true

# Creation view for Systems.
class Views::Systems::New < Views::Base
  attr_reader :available_domains, :available_owners, :system

  # Initializes the view.
  #
  # @param system [System] The system being created.
  # @param available_domains [Array<Array>] Domain entity options with name and
  #   id attributes.
  # @param available_owners [Array<Array>] Owner entity options with name and id
  #   attributes.
  def initialize(system:, available_domains:, available_owners:)
    @system = system
    @available_domains = available_domains
    @available_owners = available_owners
  end

  def view_template
    render Layouts::Application do
      template
    end
  end

  def template
    div(class: "p-6") do
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New System" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new system." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::SystemForm(system:, available_domains:, available_owners:)
      end
    end
  end
end
