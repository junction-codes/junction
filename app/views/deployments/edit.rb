# frozen_string_literal: true

# Edit view for deployments.
class Views::Deployments::Edit < Views::Base
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
    render Layouts::Application do
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
          Components::DeploymentForm(deployment:, available_components:)
        end

        aside(class: "space-y-6") do
          Components::DeploymentEditSidebar(deployment:)
        end
      end
    end
  end
end
