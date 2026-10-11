# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Renders the role editor.
      #
      # Unlike the other settings screens this is an editor, so it breaks their
      # index-and-detail shape. Saving changes what every group holding the
      # role can do, which is why the pending changes, the role's reach and the
      # danger zone sit together in a rail rather than under the form.
      class RoleForm < Base
        attr_reader :available_permissions, :role

        # Initializes the component.
        #
        # @param role [Junction::Role] The role being created or updated.
        # @param available_permissions [Array<Junction::Permission>] Every
        #   permission that may be granted.
        # @param reach [Hash] The number of entities that hold the role.
        # @option reach [Integer] :groups The number of groups holding the role.
        # @option reach [Integer] :people The number of people holding the role.
        # @param can_destroy [Boolean] Whether the role may be deleted.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(role:, available_permissions:, reach: {},
                       can_destroy: false, **user_attrs)
          @role = role
          @available_permissions = available_permissions
          @reach = reach
          @can_destroy = can_destroy

          super(**user_attrs)
        end

        def view_template
          form_with(model: role, url: junction_catalog_form_url(role), **attrs) do |form|
            div(class: "grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_300px] " \
                       "gap-6 items-start") do
              div(class: "space-y-6 min-w-0") do
                details_card(form)
                permissions_card(form)
              end

              aside(class: "space-y-6") { rail(form) }
            end
          end
        end

        private

        def default_attrs
          {
            class: "min-w-0",
            data: {
              controller: "form role-permissions",
              action: "submit->form#disable input->role-permissions#edited",
              role_permissions_total_value: available_permissions.size
            }
          }
        end

        # Renders the form for a role's details.
        #
        # A role is an entity, so it carries the same identifier and namespace
        # every catalog kind does, and both are load-bearing. The system roles
        # are recognized by name, and imported data grants roles to groups using
        # an entity reference.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def details_card(form)
          Card do |card|
            card.header { |header| header.title { t(".title") } }

            card.content(class: "space-y-4") do
              div(class: "grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4") do
                Text(form, :title, required: true)
                Slug(form, :name, help_text: t(".name_help"))
                Immutable(form, :namespace, placeholder: "default",
                                            required: true,
                                            help_text: t(".namespace_help"))
              end

              TextArea(form, :description, required: true, rows: 3)
            end
          end
        end

        # Renders the permission picker.
        #
        # A system role is shown the same grid, read-only. It stores no rows of
        # its own, and the controller refuses permission changes to it.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def permissions_card(form)
          Card do |card|
            card.header do |header|
              div(class: "flex flex-wrap items-center justify-between gap-3") do
                selected_count
                filter
              end
            end

            card.content(class: "space-y-4") do
              system_note if role.system?

              Permissions(form, :permission_ids, available_permissions:,
                          selected: selected_permissions, disabled: role.system?,
                          label: "")
              contexts_footer
            end
          end
        end

        # Renders the line saying why a system role's grid is read-only.
        def system_note
          p(class: "text-[12px] leading-5 text-text-tertiary") { t(".system_note") }
        end

        # Renders the heading with the count of selected permissions.
        def selected_count
          div(class: "flex items-center gap-3") do
            h2(class: "text-[15px] font-semibold text-foreground") do
              Junction::Role.human_attribute_name(:permissions)
            end

            span(class: "inline-flex items-center rounded-full bg-accent-subtle " \
                        "px-2.5 py-0.5 text-[11.5px] font-medium text-accent-strong") do
              span(data: { role_permissions_target: "selected" }) { selected_now.to_s }
              span(class: "ml-1") { t(".selected", total: available_permissions.size) }
            end
          end
        end

        # Renders the box that narrows the grid to one domain or context.
        def filter
          div(class: "relative w-full sm:w-[260px]") do
            icon("search", class: "absolute left-3 top-1/2 -translate-y-1/2 " \
                                  "w-[15px] h-[15px] text-text-tertiary")

            # The filter narrows the grid; it's not part of what's saved, so
            # hitting Enter in it shouldn't reach the form's submit.
            input(type: "search", placeholder: t(".filter"),
                  aria_label: t(".filter"),
                  data: { role_permissions_target: "filter",
                          action: "input->role-permissions#filter " \
                                  "keydown.enter->role-permissions#ignoreEnter" },
                  class: "w-full rounded-lg border border-border bg-background " \
                         "py-1.5 pl-9 pr-3 text-[13px] text-foreground " \
                         "placeholder:text-text-tertiary focus:outline-none " \
                         "focus:ring-2 focus:ring-ring")
          end
        end

        # Renders how many contexts are currently visible, with a link to show
        # all.
        def contexts_footer
          div(class: "flex flex-wrap items-center justify-between gap-3 " \
                     "border-t border-border pt-3 text-[11.5px] text-text-tertiary") do
            span do
              plain t(".showing_before")
              span(class: "mx-1", data: { role_permissions_target: "shown" }) { "0" }
              plain t(".showing_after", total: context_count)

              if plugin_count.positive?
                plain "  ·  "
                plain t(".plugin_contexts", count: plugin_count)
              end
            end

            a(href: "#", data: { role_permissions_target: "expand",
                                 action: "role-permissions#expand" },
              class: "font-medium text-accent-strong hover:underline") do
              t(".show_everything")
            end
          end
        end

        # Renders the right rail.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def rail(form)
          RoleChangesCard(form:)
          RoleMetadataCard(role:, reach: @reach)
          RoleDangerCard(role:, can_destroy: @can_destroy,
                         groups: @reach.fetch(:groups, 0))
        end

        # Returns the permissions the grid ticks.
        #
        # A system role stores no rows of its own. What it grants is resolved
        # from what the engine and its plugins register, so the grid reads that
        # rather than an empty list.
        #
        # @return [Array<String>] The permission strings.
        def selected_permissions
          @selected_permissions ||=
            if role.system?
              role.effective_permission_strings
            else
              role.role_permissions.map { |held| held.permission.to_s }
            end
        end

        # Counts the registered permissions the role holds.
        #
        # A stored permission outlives the plugin that registered it, and one
        # with no checkbox is not part of what this count describes.
        #
        # @return [Integer] The count.
        def selected_now
          @selected_now ||= (selected_permissions & registered_strings).size
        end

        # Returns every permission that may be granted, as a string.
        #
        # @return [Array<String>] The permission strings.
        def registered_strings
          @registered_strings ||= available_permissions.map(&:to_s)
        end

        # Counts the domains and contexts permissions are registered for.
        #
        # @return [Integer] The count.
        def context_count
          @context_count ||= available_permissions.map(&:context_path).uniq.size
        end

        # Counts the plugins registering permissions of their own.
        #
        # @return [Integer] The count.
        def plugin_count
          @plugin_count ||= Junction::PluginRegistry.plugins_registering_permissions.size
        end
      end
    end
  end
end
