# frozen_string_literal: true

# Edit view for Systems
class Views::Systems::Edit < Views::Base
  attr_reader :available_domains, :available_owners, :system

  # Initializes the view.
  #
  # @param system [System] The system being modified.
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
    render Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6 space-y-6") do
      div do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit System" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@system.name}' system." }
      end

      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          Components::SystemForm(system:, available_domains:, available_owners:)
        end

        aside(class: "space-y-6") do
          Components::SystemEditSidebar(system:)
        end
      end
    end
  end
end
