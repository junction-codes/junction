# frozen_string_literal: true

module Junction
  module Components
    class GroupForm < Base
      include Phlex::Rails::Helpers::FormWith

      def initialize(group:, available_parents:)
        @group = group
        @available_parents = available_parents
      end

      def view_template
        form_with(model: @group, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
          # Basic information section.
          render Components::Card.new do |card|
            card.header do |header|
              header.title { "Basic Information" }
              header.description { "This information will be displayed on the group's main page." }
            end

            card.content(class: "space-y-4") do
              render TextField.new(f, :name, "Group Name", required: true)
              render RichSelectField.new(f, :type, "Type", required: true, options: CatalogOptions.group_types)

              render ReferenceField.new(f, :parent_id, "Parent", required: false, icon: "users-round",
                                        options: @available_parents, value: @group.parent,
                                        help_text: "Select a parent for this group.")

              render TextField.new(f, :email, "Email", placeholder: "example@example.com")
              render TextField.new(f, :image_url, "Image URL", placeholder: "https://example.com/logo.png")
              render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief, high-level summary of the group's mission.")
            end

            annotations(f)
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
        @group.id.nil? ? groups_path : group_path(@group)
      end

      def annotations(form)
        form.fields_for :annotations, @group.annotations do |annotations_form|
          render AnnotationsForm.new(form: annotations_form, context: @group)
        end
      end
    end
  end
end
