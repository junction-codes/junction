# frozen_string_literal: true

module Junction
  module Components
    class ResourceForm < Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::OptionsForSelect

      include PluginDispatchHelper

      def initialize(resource:, available_owners:, available_systems:)
        @resource = resource
        @available_owners = available_owners
        @available_systems = available_systems
      end

      def view_template
        form_with(model: @resource, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
          # Basic information section.
          Card do |card|
            card.header do |header|
              header.title { "Resource Details" }
              header.description { "This information will be displayed on the resources's main page." }
            end

            card.content(class: "space-y-4") do
              SlugField(f, title_label: "Resource Name", required: true)
              ImmutableField(f, :namespace, "Namespace", placeholder: "default",
                             required: true,
                             tooltip_text: "The namespace cannot be changed after creation.",
                             help_text: "Namespaces allow the same identifier to exist in different contexts.")
              RichSelectField(f, :type, "Type", required: true, options: Junction::CatalogOptions.resources)

              ReferenceField(f, :owner_id, "Owner", required: true,
                             icon: "users-round", options: @available_owners,
                             value: @resource.owner,
                             help_text: "Assign an owner for this resource.")
              ReferenceField(f, :system_id, "System", icon: "users-round",
                             options: @available_systems, value: @resource.system,
                             help_text: "System this resource belongs to.")

              TextAreaField(f, :description, "Description", required: true, help_text: "A brief summary of the resource's goals.")
              TextField(f, :image_url, "Image URL", help_text: "Optional URL for an image representing this resource.")
            end
          end

          f.fields_for :annotations, @resource.annotations do |annotations_form|
            AnnotationsForm(
              form: annotations_form,
              context: @resource
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
        @resource.id.nil? ? resources_path : resource_path(@resource)
      end
    end
  end
end
