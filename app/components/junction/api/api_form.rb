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
                header.title { t(".title") }
                header.description { t(".description") }
              end

              card.content(class: "space-y-4") do
                Text(f, :title, required: true)
                Slug(f, :name)
                Immutable(f, :namespace, placeholder: "default",
                              required: true,
                              help_text: t(".namespace_help"))
                RichSelect(f, :type, required: true, options: Junction::CatalogOptions.apis)
                RichSelect(f, :lifecycle, required: true,
                                options: Junction::CatalogOptions.lifecycles)

                Reference(f, :owner_id, icon: "users-round",
                              options: @available_owners, value: @api.owner,
                              required: true,
                              help_text: t(".owner_help"))
                Reference(f, :system_id, icon: "users-round",
                              options: @available_systems, value: @api.system,
                              required: true,
                              help_text: t(".system_help"))

                TextArea(f, :description, required: true,
                              help_text: t(".description_help"))
                TextArea(f, :definition, required: true,
                              help_text: t(".definition_help"), rows: 10)
              end
            end

            f.fields_for :annotations, @api.annotations do |annotations_form|
              AnnotationsForm(form: annotations_form, context: @api)
            end

            # Form actions.
            div(class: "flex items-center justify-end gap-x-4 pt-4") do
              Link(href: cancel_path, class: "text-sm font-semibold leading-6") { t(".cancel") }
              Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
                icon("save", class: "w-4 h-4 mr-2")
                plain t(".save")
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
