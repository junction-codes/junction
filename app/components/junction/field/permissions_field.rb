# frozen_string_literal: true

module Junction
  module Components
    # Form field for selecting permissions.
    #
    # Renders permissions grouped by domain/context, then by all vs owned. Each
    # checkbox is labeled by access level with a tooltip for the full
    # description.
    class PermissionsField < Base
      # Initialize a new component.
      #
      # @param form [ActionView::Helpers::FormBuilder] The form builder.
      # @param method [Symbol] Method name for the field.
      # @param label [String] The label for the field.
      # @param available_permissions [Array<Junction::Permission>] Available
      #   permissions to select from.
      # @param help_text [String] Optional help text for the field.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(form, method, label, available_permissions:, help_text: nil, **user_attrs)
        @form = form
        @method = method
        @label = label
        @available_permissions = available_permissions
        @help_text = help_text
        @role = form.object

        super(**user_attrs)
      end

      def view_template
        div(**attrs) do
          if @label.present?
            div(class: "block text-sm font-medium leading-6 text-gray-900 dark:text-white mb-2") do
              plain @label
            end
          end

          p(class: "mb-4 text-sm text-gray-500 dark:text-gray-400") { @help_text } if @help_text

          div(class: "max-h-[32rem] overflow-y-auto") do
            div(class: "grid grid-cols-1 lg:grid-cols-2 gap-4") do
              grouped_permissions.each do |title, permissions|
                render_permission_block(permissions, title)
              end
            end
          end
        end
      end

      private

      # Groups permissions by domain and context.
      #
      # @return [Array<Array<String, Array<Junction::Permission>>>] The grouped
      #   permissions.
      def grouped_permissions
        @grouped_permissions ||= @available_permissions.group_by do |permission|
          "#{permission.domain}/#{permission.context}"
        end.sort_by { |key, _| key }.map { |key, perms| [ key, perms.sort_by(&:to_s) ] }
      end

      # Filters permissions by ownership.
      #
      # @param permissions [Array<Junction::Permission>] The permissions to
      #   filter.
      # @param ownership [Symbol] The ownership to filter by.
      # @return [Array<Junction::Permission>] The requested permissions.
      def permissions_for_ownership(permissions, ownership)
        permissions.select { |p| p.ownership == ownership }
      end

      # The permissions that are currently selected.
      #
      # @return [Set<String>] The selected permissions.
      def selected_permissions
        @selected_permissions ||= @role.role_permissions.pluck(:permission).to_set
      end

      # Renders a block of permissions for a given group.
      #
      # @param perms [Array<Junction::Permission>] The permissions to render.
      # @param title [String] Title of the group.
      def render_permission_block(permissions, title)
        div(class: "min-w-0 rounded-lg border border-gray-200 dark:border-gray-700 p-4 lg:min-w-[10rem]") do
          h4(class: "break-words text-sm font-semibold text-gray-900 dark:text-white mb-3") { title }

          div(class: "grid w-full grid-cols-1 gap-4 sm:grid-cols-2") do
            Junction::Permission::Ownership::VALUES.each do |ownership|
              render_ownership_permissions(
                permissions_for_ownership(permissions, ownership),
                ownership.titleize
              )
            end
          end
        end
      end

      # Renders a block of permissions for a given ownership level.
      #
      # @param permissions [Array<Junction::Permission>] The permissions to
      #   render.
      # @param title [String] The title of the ownership level.
      def render_ownership_permissions(permissions, title)
        return if permissions.empty?

        div(class: "min-w-0 space-y-2") do
          span(class: "text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-gray-400") do
            plain title
          end

          permissions.sort_by(&:to_s).each { |perm| render_permission_checkbox(perm) }
        end
      end

      # Renders a checkbox for a given permission.
      #
      # @param permission [Junction::Permission] The permission to render.
      def render_permission_checkbox(permission)
        div(class: "flex min-w-0 items-center gap-2") do
          input(
            type: "checkbox",
            name: "#{@form.object_name}[#{@method}][]",
            id: "role_permission_#{permission.to_s.parameterize}",
            value: permission.to_s,
            checked: selected_permissions.include?(permission.to_s),
            class: "h-4 w-4 rounded border-gray-300"
          )

          label(
            for: "role_permission_#{permission.to_s.parameterize}",
            title: permission.description.presence || permission.to_s,
            class: "cursor-help text-sm text-gray-700 dark:text-gray-300"
          ) do
            plain permission.access.capitalize
          end
        end
      end
    end
  end
end
