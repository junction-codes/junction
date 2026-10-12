# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Renders the pending changes to a role's permission set, and the save
      # button.
      #
      # Saving a role changes what every group holding it can do, so the
      # permissions being added and removed are listed before the save button.
      class RoleChangesCard < Base
        # Initializes the component.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(form:, **user_attrs)
          @form = form

          super(**user_attrs)
        end

        def view_template
          Card(**attrs) do |card|
            card.header { heading }

            card.content(class: "space-y-4") do
              nothing_yet
              ul(class: "space-y-1", data: { role_permissions_target: "diff" })
              actions
            end
          end
        end

        private

        # Renders the title and the count of pending changes.
        def heading
          div(class: "flex items-center justify-between gap-2") do
            h2(class: "text-[15px] font-semibold text-foreground") { t(".title") }

            span(class: "inline-flex h-5 min-w-5 items-center justify-center " \
                        "rounded-full bg-warning-subtle px-1.5 text-[11px] " \
                        "font-medium tabular-nums text-warning",
                 data: { role_permissions_target: "count" }, hidden: true) { "0" }
          end
        end

        # Renders the line shown while nothing has changed.
        def nothing_yet
          p(class: "text-[12.5px] text-text-tertiary",
            data: { role_permissions_target: "empty" }) { t(".empty") }
        end

        # Renders the save and cancel actions.
        def actions
          div(class: "flex items-center gap-3 pt-1") do
            Button(type: "submit", variant: :primary, class: "flex-1 justify-center",
                   disabled: true,
                   data: { role_permissions_target: "save", form_target: "submit" }) do
              icon("save", class: "w-4 h-4 mr-2")
              plain t(".save")
            end

            Link(href: cancel_path, class: "text-sm font-semibold leading-6") do
              t(".cancel")
            end
          end
        end

        # Path where the cancel link should take the user.
        #
        # @return [String] The path.
        def cancel_path
          role = @form.object

          role.persisted? ? junction_catalog_path(role) : roles_path
        end
      end
    end
  end
end
