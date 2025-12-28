# frozen_string_literal: true

# Edit view for groups.
class Views::Groups::Edit < Views::Base
  attr_reader :available_parents, :group

  # Initializes the view.
  #
  # @param group [Group] The group being modified.
  # @param available_parents [Array<Array>] Parent entity options with name and
  #   id attributes.
  def initialize(group:, available_parents:)
    @group = group
    @available_parents = available_parents
  end

  def view_template
    render Layouts::Application do
      template
    end
  end

  def template
    div(class: "p-6 space-y-6") do
      # Page header.
      div do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Group" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@group.name}' group." }
      end

      # Two-column layout for form and sidebar.
      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          Components::GroupForm(group:, available_parents:)
        end

        aside(class: "space-y-6") do
          Components::GroupEditSidebar(group:)
        end
      end
    end
  end
end
