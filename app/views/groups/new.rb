# frozen_string_literal: true

class Views::Groups::New < Views::Base
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
    div(class: "p-6") do
      # Page header.
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Group" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new group." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        render Components::GroupForm.new(group: @group, parents: @parents)
      end
    end
  end
end
