# frozen_string_literal: true

module Junction
  module Components
    module Resource
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
          form_with(model: @resource, url: junction_catalog_form_url(@resource), class: "space-y-8",
                    data: { controller: "form", action: "submit->form#disable" }) do |f|
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
                RichSelect(f, :type, required: true, options: Junction::CatalogOptions.resources)

                Reference(f, :owner_id, required: true,
                              icon: "users-round", options: @available_owners,
                              value: @resource.owner,
                              help_text: t(".owner_help"))
                Reference(f, :system_id, icon: "users-round",
                              options: @available_systems, value: @resource.system,
                              help_text: t(".system_help"))

                TextArea(f, :description, required: true, help_text: t(".description_help"))
                Text(f, :image_url, help_text: t(".image_url_help"))
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
          @resource.id.nil? ? resources_path : junction_catalog_path(@resource)
        end
      end
    end
  end
end
