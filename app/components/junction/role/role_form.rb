# frozen_string_literal: true

module Junction
  module Components
    # Form for creating and editing roles.
    class RoleForm < Base
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
        form_with(model: @role, **attrs) do |f|
          render Card do |card|
            card.header do |header|
              header.title { t("components.role_form.basic_info_title") }
              header.description { t("components.role_form.basic_info_description") }
            end

            card.content(class: "space-y-4") do
              render TextField.new(f, :name, t("components.role_form.role_name_label"), required: true)
              render TextAreaField.new(f, :description, t("components.role_form.description_label"), required: true)
            end
          end

          unless @role.system?
            render Card do |card|
              card.header do |header|
                header.title { t("components.role_form.permissions_title") }
                header.description { t("components.role_form.permissions_description") }
              end

              card.content(class: "space-y-2 max-h-96 overflow-y-auto") do
                selected = @role.role_permissions.pluck(:permission).to_set
                @available_permissions.each do |perm|
                  div(class: "flex items-center gap-2") do
                    input(
                      type: "checkbox",
                      name: "role[permission_ids][]",
                      id: "role_permission_#{perm.to_s.parameterize}",
                      value: perm.to_s,
                      checked: selected.include?(perm.to_s),
                      class: "h-4 w-4 rounded border-gray-300"
                    )

                    label(for: "role_permission_#{perm.to_s.parameterize}",
                          class: "text-sm text-gray-700 dark:text-gray-300") do
                      plain perm.description.presence || perm.to_s
                    end
                  end
                end
              end
            end
          end

          div(class: "flex items-center justify-end gap-x-4 pt-4") do
            Link(href: cancel_path, class: "text-sm font-semibold leading-6") { t("components.role_form.cancel") }
            Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
              icon("save", class: "w-4 h-4 mr-2")
              plain t("components.role_form.save")
            end
          end
        end
      end

      private

      # Path to return the user to if they cancel the form.
      #
      # @return [String] The path to return the user to.
      def cancel_path
        @role.persisted? ? role_path(@role) : roles_path
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
