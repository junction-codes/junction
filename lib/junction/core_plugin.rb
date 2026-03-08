# frozen_string_literal: true

module Junction
  # Represents the Junction engine's core plugin.
  class CorePlugin < ApplicationPlugin
    ANNOTATION_GROUP_ROLE = "junction.codes/role"
    DOMAIN = "junction.codes"

    domain DOMAIN
    description "Junction Core plugin"
    icon "layout-grid"
    title "Junction Core"
    plugin_name "junction"

    {
      apis:        { role: false, ownership: true },
      components:  { role: false, ownership: true },
      dashboards:  { role: false, ownership: false, class: "Dashboard" },
      domains:     { role: false, ownership: true },
      groups:      { role: true,  ownership: false },
      resources:   { role: false, ownership: true },
      roles:       { role: false, ownership: false },
      systems:     { role: false, ownership: true },
      users:       { role: false, ownership: false }
    }.each do |context_sym, options|
      if options[:role]
        entity = options[:class] || "Junction::#{context_sym.to_s.singularize.classify}"
        for_entity(entity) do |s|
          s.annotation(key: ANNOTATION_GROUP_ROLE, title: "Role", placeholder: "Role name")
        end
      end

      Permission::Access::VALUES.each do |access|
        permission(
          context: context_sym.to_s,
          ownership: "all",
          access:,
          description: "#{access.titleize} access to all #{context_sym.to_s.pluralize}"
        )

        next unless options[:ownership]

        permission(
          context: context_sym.to_s,
          ownership: "owned",
          access:,
          description: "#{access.titleize} access to owned #{context_sym.to_s.pluralize}"
        )
      end
    end
  end
end
