# frozen_string_literal: true

module Junction
  module Components
    module Component
      class ComponentForm < Base
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::OptionsForSelect

        include PluginDispatchHelper

        def initialize(component:, available_owners:, available_systems:)
          @component = component
          @available_owners = available_owners
          @available_systems = available_systems
        end

        def view_template
          form_with(model: @component, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
            # Basic information section.
            Card do |card|
              card.header do |header|
                header.title { "Component Details" }
                header.description { "This information will be displayed on the component's main page." }
              end

              card.content(class: "space-y-4") do
                Text(f, :title, required: true)
                Slug(f, :name)
                Immutable(f, :namespace, placeholder: "default",
                              required: true,
                              help_text: "Namespaces allow the same identifier to exist in different contexts.")
                RichSelect(f, :type, required: true, options: Junction::CatalogOptions.kinds)
                RichSelect(f, :lifecycle, required: true,
                                options: Junction::CatalogOptions.lifecycles)

                Reference(f, :owner_id, icon: "users-round",
                              options: @available_owners, value: @component.owner,
                              help_text: "Assign an owner for this component.")
                Reference(f, :system_id, icon: "users-round",
                              options: @available_systems, value: @component.system,
                              help_text: "System this resource belongs to.")

                Text(f, :repository_url)
                TextArea(f, :description, required: true,
                              help_text: "A brief summary of the component's goals.")
              end
            end

            f.fields_for :annotations, @component.annotations do |annotations_form|
              AnnotationsForm(
                form: annotations_form,
                context: @component
              )
            end

            # Form actions.
            div(class: "flex items-center justify-end gap-x-4 pt-4") do
              Link(href: cancel_path, class: "text-sm font-semibold leading-6") { "Cancel" }
              Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
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
  end
end
