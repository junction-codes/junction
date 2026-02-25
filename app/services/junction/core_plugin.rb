# frozen_string_literal: true

module Junction
  # Represents the Junction engine's core plugin.
  module CorePlugin
    DOMAIN = "junction.codes"
    ANNOTATION_GROUP_ROLE = "junction.codes/role"

    module_function

    # Register the core plugin with the plugin registry.
    def register
      plugin = Plugin.new("junction", Junction, icon: "layout-grid", title: "Junction")
      register_permissions(plugin)
      plugin.register
    end

    # Register the permissions for the core plugin.
    #
    # @param plugin [Plugin] The plugin to register the permissions for.
    def register_permissions(plugin)
      contexts = {
        apis: { role: false, ownership: true },
        components: { role: false, ownership: true },
        dashboards: { role: false, ownership: false, class: "Dashboard" },
        deployments: { role: false, ownership: true },
        domains: { role: false, ownership: true },
        groups: { role: true, ownership: false },
        resources: { role: false, ownership: true },
        roles: { role: false, ownership: false },
        systems: { role: false, ownership: true },
        users: { role: false, ownership: false }
      }.freeze

      contexts.each do |context, options|
        entity = options[:class] || "Junction::#{context.to_s.singularize.classify}"
        plugin.for_entity(entity) do |s|
          if options[:role]
            s.annotation(key: ANNOTATION_GROUP_ROLE, title: "Role", placeholder: "Role name")
          end

          Permission::Access::VALUES.each do |access|
            s.permission(domain: DOMAIN, context:, ownership: "all",
                         access:, description: "#{access.titleize} access to all #{context.to_s.pluralize}")
            next unless options[:ownership]

            s.permission(domain: DOMAIN, context:, ownership: "owned",
                         access:, description: "#{access.titleize} access to owned #{context.to_s.pluralize}")
          end
        end
      end
    end
  end
end
