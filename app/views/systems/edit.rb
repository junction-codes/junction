# frozen_string_literal: true

class Views::Systems::Edit < Views::Base
  def initialize(system:, owners:)
    @system = system
    @owners = owners
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
          render Components::SystemForm.new(system: @system, owners: @owners)
        end

        aside(class: "space-y-6") do
          render Components::SystemEditSidebar.new(system: @system)
        end
      end
    end
  end
end
