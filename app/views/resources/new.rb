# frozen_string_literal: true

class Views::Resources::New < Views::Base
  def initialize(resource:, owners:)
    @resource = resource
    @owners = owners
  end

  def view_template
    render Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6") do
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Resource" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new rsource." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        render Components::ResourceForm.new(resource: @resource, owners: @owners)
      end
    end
  end
end
