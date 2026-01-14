# frozen_string_literal: true

module Junction
  module Components
    class ApiForm < Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::OptionsForSelect

      include PluginDispatchHelper

      def initialize(api:, available_owners:, available_systems:)
        @api = api
        @available_owners = available_owners
        @available_systems = available_systems
      end

      def view_template
        form_with(model: @api, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
          # Basic information section.
          render Components::Card.new do |card|
            card.header do |header|
              header.title { "API Details" }
              header.description { "This information will be displayed on the API's main page." }
            end

            card.content(class: "space-y-4") do
              render TextField.new(f, :name, "API Name", required: true)
              render RichSelectField.new(f, :type, "Type", required: true, options: CatalogOptions.apis)
              render RichSelectField.new(f, :lifecycle, "Lifecycle", required: true, options: CatalogOptions.lifecycles)

              render ReferenceField.new(f, :owner_id, "Owner", icon: "users-round",
                                        options: @available_owners, value: @api.owner, required: true,
                                        help_text: "Assign an owner for this API.")
              render ReferenceField.new(f, :system_id, "System", icon: "users-round",
                                        options: @available_systems, value: @api.system, required: true,
                                        help_text: "System this API belongs to.")

              render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief summary of the component's goals.")
              render TextAreaField.new(f, :definition, "Definition", required: true, help_text: "API spec definition.", rows: 10)
            end
          end

          f.fields_for :annotations, @api.annotations do |annotations_form|
            render(AnnotationsForm.new(
              form: annotations_form,
              context: @api
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
        @api.id.nil? ? apis_path : api_path(@api)
      end
    end
  end
end
