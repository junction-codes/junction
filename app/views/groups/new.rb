# frozen_string_literal: true

# Creation view for groups.
class Views::Groups::New < Views::Base
  attr_reader :available_parents, :group

  # Initializes the view.
  #
  # @param group [Group] The group being created.
  # @param available_parents [Array<Array>] Parent entity options with name and
  #   id attributes.
  def initialize(group:, available_parents:)
    @group = group
    @available_parents = available_parents
  end

  def view_template
    render Junction::Layouts::Application do
      template
    end
  end

  def template
    div(class: "p-6") do
      # Page header.
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Group" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new group." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::GroupForm(group:, available_parents:)
      end
    end
  end
end
