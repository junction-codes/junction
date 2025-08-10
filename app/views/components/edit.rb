# frozen_string_literal: true

class Views::Components::Edit < Views::Base
  def initialize(component:)
    @component = component
  end

  def view_template
    render Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6 space-y-6") do
      div do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Component" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the '#{@component.name}' component." }
      end

      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          render Components::ComponentForm.new(component: @component)
        end

        aside(class: "space-y-6") do
          render Components::ComponentEditSidebar.new(component: @component)
        end
      end
    end
  end
end
