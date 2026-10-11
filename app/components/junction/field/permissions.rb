# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Renders the permission picker.
      #
      # A permission combines a domain, a context, an access level and an
      # ownership scope, which is four decisions in one string. As a grid the
      # reader makes them one at a time: the block says which context, the row
      # says how much of it, and the column says what may be done.
      #
      # Only registered permissions get a checkbox.
      class Permissions < FieldType
        # The access levels, in the order they escalate.
        ACCESS = Junction::Permission::Access::VALUES

        # The ownership scopes, widest first.
        OWNERSHIP = Junction::Permission::Ownership::VALUES

        # Initializes the field.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param method [Symbol] Method name for the field.
        # @param available_permissions [Array<Junction::Permission>] Every
        #   permission that may be granted.
        # @param selected [Enumerable<String>] The permissions to tick.
        #   Defaults to the rows the record stores.
        # @param disabled [Boolean] Whether the grid is read-only, for a role
        #   whose permissions are resolved rather than stored.
        # @param label [String] Human-readable label for the field; set to an
        #   empty string to omit.
        # @param help_text [String] Help text for the field.
        # @param required [Boolean] Whether the field is required.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(form, method, available_permissions:, selected: nil,
                       disabled: false, label: nil, help_text: nil,
                       required: false, **user_attrs)
          @available_permissions = available_permissions
          @selected = selected
          @disabled = disabled

          super(form, method, label:, help_text:, required:, **user_attrs)
        end

        def view_template
          div(**attrs) do
            render_label
            blocks
          end
        end

        private

        def default_attrs
          { class: "min-w-0" }
        end

        # Renders the grid of contexts.
        def blocks
          div(class: "grid grid-cols-1 xl:grid-cols-2 gap-4") do
            contexts.each { |context, permissions| block(context, permissions) }
          end
        end

        # Renders a block for a single context.
        #
        # @param context [String] The domain and context.
        # @param permissions [Hash] The context's permissions, by scope and
        #   access.
        def block(context, permissions)
          div(class: "min-w-0 rounded-[10px] border border-border bg-background " \
                     "p-4 space-y-3",
              data: { role_permissions_target: "block", context: context.downcase },
              hidden: true) do
            span(class: "block truncate font-mono text-[12.5px] text-text-strong") do
              context
            end

            div(class: "grid gap-y-2 items-center",
                style: "grid-template-columns: 1fr repeat(#{ACCESS.size}, 56px)") do
              column_heads
              OWNERSHIP.each { |scope| scope_row(context, scope, permissions) }
            end
          end
        end

        # Renders the headers for the access columns.
        def column_heads
          span
          ACCESS.each do |access|
            span(class: "text-center text-[11px] font-medium uppercase " \
                        "tracking-wide text-text-tertiary") { access }
          end
        end

        # Renders one ownership scope's row of checkboxes.
        #
        # @param context [String] The domain and context.
        # @param scope [String] Ownership scope.
        # @param permissions [Hash] The context's permissions, by scope and
        #   access.
        def scope_row(context, scope, permissions)
          span(class: "text-[12.5px] text-text-body") { scope.titleize }

          ACCESS.each do |access|
            permission = permissions.dig(scope, access)

            div(class: "flex justify-center") do
              permission ? checkbox(permission) : unregistered
            end
          end
        end

        # Renders one permission's checkbox, with what it allows on hover.
        #
        # The grid names the context, the scope and the access, but not what a
        # plugin meant by them, so the permission's own description is the only
        # place that says what granting it allows. The tooltip opens on focus
        # as well as hover, so it's reachable from the keyboard.
        #
        # @param permission [Junction::Permission] The permission.
        def checkbox(permission)
          Tooltip do |tooltip|
            tooltip.trigger { checkbox_input(permission) }
            tooltip.content { permission.description.presence || permission.to_s }
          end
        end

        # Renders the checkbox itself.
        #
        # The box carries the state it loaded with, which is what the editor
        # compares against to work out what's being added and removed.
        #
        # @param permission [Junction::Permission] The permission.
        def checkbox_input(permission)
          string = permission.to_s
          checked = selected_permissions.include?(string)

          input(type: "checkbox", name: "#{entity_type}[#{@method}][]",
                id: "role_permission_#{string.parameterize}",
                value: string, checked:, disabled: @disabled,
                aria_label: string,
                data: { role_permissions_target: "checkbox",
                        action: "role-permissions#toggle",
                        permission: string, initial: checked.to_s },
                class: "h-[17px] w-[17px] rounded border-border " \
                       "text-accent-solid focus:ring-ring " \
                       "disabled:cursor-default disabled:opacity-70")
        end

        # Renders the mark for an access level nothing registers for a context.
        def unregistered
          span(class: "text-text-tertiary/40") do
            span(aria_hidden: "true") { "·" }
            span(class: "sr-only") { t(".not_registered") }
          end
        end

        # Returns every permission that may be granted, by context, scope and
        # access.
        #
        # @return [Hash<String, Hash>] The permissions.
        def contexts
          @contexts ||= @available_permissions
                        .group_by(&:context_path)
                        .sort.to_h do |context, permissions|
            [ context, permissions.group_by { |p| p.ownership.to_s }
                                  .transform_values { |scoped| scoped.index_by { |p| p.access.to_s } } ]
          end
        end

        # Returns the permissions to tick.
        #
        # @return [Set<String>] The permission strings.
        def selected_permissions
          @selected_permissions ||=
            (@selected || entity.role_permissions.map { |held| held.permission.to_s }).to_set
        end
      end
    end
  end
end
