# frozen_string_literal: true

module Components
  class ComponentForm < Base
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::OptionsForSelect

    include PluginDispatchHelper

    def initialize(component:, domains: Domain.order(:name), owners: Group.order(:name))
      @component = component
      @domains = domains
      @owners = owners
    end

    def view_template
      form_with(model: @component, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "Component Details" }
            header.description { "This information will be displayed on the component's main page." }
          end

          card.content(class: "space-y-4") do
            render TextField.new(f, :name, "Component Name", required: true)
            render RichSelectField.new(f, :type, "Type", required: true, options: CatalogOptions.kinds)
            render RichSelectField.new(f, :lifecycle, "Lifecycle", required: true, options: CatalogOptions.lifecycles)

            render ReferenceField.new(f, :domain_id, "Domain", required: true,
                                   options: @domains, value: @component.domain, icon: "briefcase",
                                   help_text: "Assign this component to an existing domain.")

            render ReferenceField.new(f, :owner_id, "Owner", icon: "users-round",
                                      options: @owners, value: @component.owner,
                                      help_text: "Assign an owner for this component.")

            render TextField.new(f, :repository_url, "Repository URL")
            render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief summary of the component's goals.")
          end
        end

        f.fields_for :annotations, @component.annotations do |annotations_form|
          render(AnnotationsForm.new(
            form: annotations_form,
            context: @component
          ))
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
      @component.id.nil? ? components_path : component_path(@component)
    end
  end
end
