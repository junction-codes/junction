# frozen_string_literal: true

# Edit view for resources.
class Views::Resources::Edit < Views::Base
  attr_reader :available_owners, :available_systems, :resource

  # Initializes the view.
  #
  # @param resource [Resource] The resource being modified.
  # @param available_owners [Array<Array>] Owner entity options with name and
  #   id attributes.
  # @param available_systems [Array<Array>] System entity options with name and
  #  id attributes.
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
    div(class: "p-6 space-y-6") do
      div do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Resource" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@resource.name}' resrouce." }
      end

      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          Components::ResourceForm(resource:, available_owners:, available_systems:)
        end

        aside(class: "space-y-6") do
          Components::ResourceEditSidebar(resource:)
        end
      end
    end
  end
end
