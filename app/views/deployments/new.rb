# frozen_string_literal: true

# Creation view for deployments.
class Views::Deployments::New < Views::Base
  attr_reader :available_components, :deployment

  # Initializes the view.
  #
  # @param deployment [Deployment] The deployment being modified.
  # @param available_components [Array<Array>] Component entity options with
  #   name and id attributes.
  def initialize(deployment:, available_components:)
    @deployment = deployment
    @available_components = available_components
  end

  def view_template
    render Junction::Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6") do
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Deployment" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new deployment." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        Components::DeploymentForm(deployment:, available_components:)
      end
    end
  end
end
