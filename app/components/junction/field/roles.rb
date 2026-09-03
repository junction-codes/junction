# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for granting roles to a group.
      #
      # Rendered only for users who may manage roles: a grant is a privilege
      # change, so it is gated separately from editing the group itself.
      class Roles < FieldType
        # Initialize a new field component.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param method [Symbol] Method name for the field.
        # @param available_roles [ActiveRecord::Relation] Roles to choose from.
        # @param label [String] Optional, human-readable label for the field.
        # @param help_text [String] Optional help text for the field.
        # @param required [Boolean] Whether the field is required.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(form, method, available_roles:, label: nil,
                       help_text: nil, required: false, **user_attrs)
          @available_roles = available_roles

          super(form, method, label:, help_text:, required:, **user_attrs)
        end

        def view_template
          div(**attrs) do
            render_label

            if @help_text
              p(class: "mb-4 text-sm text-gray-500 dark:text-gray-400") { @help_text }
            end

            # Submitted even when every box is cleared, so removing the last
            # role is a real change rather than an omitted parameter.
            input(type: "hidden", name: "#{entity_type}[#{@method}][]", value: "")

            div(class: "space-y-2") do
              @available_roles.each { |role| render_role_checkbox(role) }
            end
          end
        end

        private

        # IDs of the roles currently granted.
        #
        # @return [Set<Integer>] The granted role IDs.
        def selected_role_ids
          @selected_role_ids ||= entity.role_ids.to_set
        end

        # Renders a checkbox for a given role.
        #
        # @param role [Junction::Role] The role to render.
        def render_role_checkbox(role)
          field_id = "group_role_#{role.id}"

          div(class: "flex min-w-0 items-center gap-2") do
            input(
              type: "checkbox",
              name: "#{entity_type}[#{@method}][]",
              id: field_id,
              value: role.id,
              checked: selected_role_ids.include?(role.id),
              class: "h-4 w-4 rounded border-gray-300"
            )

            label(for: field_id, class: "text-sm text-gray-700 dark:text-gray-300") do
              plain role.title
            end

            if role.description.present?
              span(class: "text-xs text-gray-500 dark:text-gray-400") { role.description }
            end
          end
        end
      end
    end
  end
end
