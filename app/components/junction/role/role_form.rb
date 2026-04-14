# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Form for creating and editing roles.
      class RoleForm < Base
        attr_reader :available_permissions, :role

        # Initialize a new component.
        #
        # @param role [Junction::Role] The role being created or updated.
        # @param available_permissions [Array<Junction::Permission>] Available
        #   permissions to select from.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(role:, available_permissions:, **user_attrs)
          @role = role
          @available_permissions = available_permissions

          super(**user_attrs)
        end

        def view_template
          form_with(model: @role, url: junction_catalog_form_url(@role), **attrs) do |f|
            Card do |card|
              card.header do |header|
                header.title { t(".title") }
                header.description { t(".description") }
              end

              card.content(class: "space-y-4") do
                Text(f, :title, required: true)
                Slug(f, :name)
                Immutable(f, :namespace, required: true,
                              help_text: t(".namespace_help"))
                TextArea(f, :description, required: true)
              end
            end

            unless @role.system?
              Card do |card|
                card.header do |header|
                  header.title { @role.class.human_attribute_name(:permissions) }
                  header.description { t(".permissions_description") }
                end

                card.content do
                  Permissions(f, :permission_ids, available_permissions:)
                end
              end
            end

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

        # Path to return the user to if they cancel the form.
        #
        # @return [String] The path to return the user to.
        def cancel_path
          @role.persisted? ? junction_catalog_path(@role) : roles_path
        end

        def default_attrs
          {
            class: "space-y-8",
            data: { controller: "form", action: "submit->form#disable" }
          }
        end
      end
    end
  end
end
