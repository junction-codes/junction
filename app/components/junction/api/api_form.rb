# frozen_string_literal: true

module Junction
  module Components
    module Api
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
            Card do |card|
              card.header do |header|
                header.title { "API Details" }
                header.description { "This information will be displayed on the API's main page." }
              end

              card.content(class: "space-y-4") do
                Text(f, :title, required: true)
                Slug(f, :name)
                Immutable(f, :namespace, placeholder: "default",
                              required: true,
                              help_text: "Namespaces allow the same identifier to exist in different contexts.")
                RichSelect(f, :type, required: true, options: Junction::CatalogOptions.apis)
                RichSelect(f, :lifecycle, required: true,
                                options: Junction::CatalogOptions.lifecycles)

                Reference(f, :owner_id, icon: "users-round",
                              options: @available_owners, value: @api.owner,
                              required: true,
                              help_text: "Assign an owner for this API.")
                Reference(f, :system_id, icon: "users-round",
                              options: @available_systems, value: @api.system,
                              required: true,
                              help_text: "System this API belongs to.")

                TextArea(f, :description, required: true,
                              help_text: "A brief summary of the component's goals.")
                TextArea(f, :definition, required: true,
                              help_text: "API spec definition.", rows: 10)
              end
            end

            f.fields_for :annotations, @api.annotations do |annotations_form|
              AnnotationsForm(form: annotations_form, context: @api)
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
          @api.id.nil? ? apis_path : api_path(@api)
        end
      end
    end
  end
end
