# frozen_string_literal: true

class Views::Deployments::Edit < Views::Base
  def initialize(deployment:)
    @deployment = deployment
  end

  def view_template
    render Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6 space-y-6") do
      div do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Edit Deployment" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Update the details for the current deployment." }
      end

      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main(class: "lg:col-span-2") do
          render Components::DeploymentForm.new(deployment: @deployment)
        end

        aside(class: "space-y-6") do
          render Components::DeploymentEditSidebar.new(deployment: @deployment)
        end
      end
    end
  end
end
