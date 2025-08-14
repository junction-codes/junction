# frozen_string_literal: true

class Views::Groups::Edit < Views::Base
  def initialize(group:, parents:)
    @group = group
    @parents = parents
  end

  def view_template
    render Layouts::Application.new do
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
          render Components::GroupForm.new(group: @group, parents: @parents)
        end

        aside(class: "space-y-6") do
          render Components::GroupEditSidebar.new(group: @group)
        end
      end
    end
  end
end
