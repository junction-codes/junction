# frozen_string_literal: true

module Junction
  module Components
    module Group
      # Form for creating and editing groups.
      class GroupForm < Base
        def initialize(group:, available_parents:)
          @group = group
          @available_parents = available_parents
        end

        def view_template
          form_with(model: @group, url: junction_catalog_form_url(@group), class: "space-y-8",
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
                RichSelect(f, :type, required: true,
                                options: Junction::CatalogOptions.group_types)

                Reference(f, :parent_id, required: false, icon: "users-round",
                              options: @available_parents, value: @group.parent,
                              help_text: t(".parent_help"))

                Text(f, :email, placeholder: "example@example.com")
                Text(f, :image_url, placeholder: "https://example.com/logo.png")
                TextArea(f, :description, required: true,
                              help_text: t(".description_help"))
              end
            end

            f.fields_for :annotations, @group.annotations do |annotations_form|
              AnnotationsForm(
                form: annotations_form,
                context: @group
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
          @group.id.nil? ? groups_path : junction_catalog_path(@group)
        end
      end
    end
  end
end
