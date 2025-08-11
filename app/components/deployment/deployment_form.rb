# frozen_string_literal: true

module Components
  class DeploymentForm < Base
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::OptionsForSelect

    def initialize(deployment:, components: Component.order(:name))
      @deployment = deployment
      @components = components
    end

    def view_template
      form_with(model: @deployment, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "Deployment Details" }
            header.description { "This information will be displayed on the deployment's main page." }
          end

          card.content(class: "space-y-4") do
            render RichSelectField.new(f, :environment, "Environment", required: true, options: CatalogOptions.environments)
            render RichSelectField.new(f, :platform, "Platform", required: true, options: CatalogOptions.platforms)

            render ReferenceField.new(f, :component_id, "Component", required: true,
                                   options: @components, value: @deployment.component, icon: "server",
                                   help_text: "Select the component this is a deployment of.")

            render TextField.new(f, :location_identifier, "Identifier")
          end
        end

        # Form actions.
        div(class: "flex items-center justify-end gap-x-4 pt-4") do
          render Link.new(href: cancel_path, class: "text-sm font-semibold leading-6") { "Cancel" }
          render Button.new(type: "submit", variant: :primary, data: { form_target: "submit" }) do
            icon("save", class: "w-4 h-4 mr-2")
            plain "Save Changes"
          end
        end
      end
    end

    private

    def cancel_path
      @deployment.id.nil? ? deployments_path : deployment_path(@deployment)
    end
  end
end
