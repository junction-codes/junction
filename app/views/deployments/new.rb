# frozen_string_literal: true

class Views::Deployments::New < Views::Base
  def initialize(deployment:)
    @deployment = deployment
  end

  def view_template
    render Layouts::Application.new do
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
        render Components::DeploymentForm.new(deployment: @deployment)
      end
    end
  end
end
