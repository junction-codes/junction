# frozen_string_literal: true

module Junction
  # Represents the Junction engine's core plugin.
  class CorePlugin < ApplicationPlugin
    ANNOTATION_GROUP_ROLE = "junction.codes/role"
    DOMAIN = "junction.codes"

    domain DOMAIN
    description "Junction Core plugin"
    icon "train-track"
    title "Junction Core"
    plugin_name "junction"

    # Entity permissions come from the kind registry, so registering a kind is
    # all it takes to declare its permissions. Contexts are persisted in
    # junction_role_permissions, and the registry derives them from each kind's
    # scope, which is why a scope may not be renamed casually.
    Junction::Kinds.all.each do |kind|
      Permission::Access::VALUES.each do |access|
        permission(
          context: kind.context,
          ownership: "all",
          access:,
          description: "#{access.titleize} access to all #{kind.context}"
        )

        next unless kind.ownable?

        permission(
          context: kind.context,
          ownership: "owned",
          access:,
          description: "#{access.titleize} access to owned #{kind.context}"
        )
      end
    end

    # The dashboard is not a kind, but it is permissioned like one.
    Permission::Access::VALUES.each do |access|
      permission(
        context: "dashboards",
        ownership: "all",
        access:,
        description: "#{access.titleize} access to all dashboards"
      )
    end

    for_entity("Junction::Group") do |s|
      s.annotation(key: ANNOTATION_GROUP_ROLE, title: "Role", placeholder: "Role name")
    end

    permission(
      context: "plugins",
      ownership: "all",
      access: :read,
      description: "Read access to all plugins"
    )

    permission(
      context: "options",
      ownership: "all",
      access: :read,
      description: "Read access to catalog options"
    )

    permission(
      context: "annotations",
      ownership: "all",
      access: :read,
      description: "Read access to annotations overview"
    )

    settings_menu_item(
      action: :roles_path,
      title_i18n: "junction.components.sidebar.sidebar.roles",
      icon: "shield-check",
      access: { action: :index?, record: :roles }
    )

    settings_menu_item(
      action: :plugins_path,
      title_i18n: "junction.components.sidebar.sidebar.plugins",
      icon: "blocks",
      access: { action: :index?, record: :plugins }
    )

    settings_menu_item(
      action: :options_path,
      title_i18n: "junction.components.sidebar.sidebar.options",
      icon: "list-filter",
      access: { action: :index?, record: :options }
    )

    settings_menu_item(
      action: :annotations_path,
      title_i18n: "junction.components.sidebar.sidebar.annotations",
      icon: "tags",
      access: { action: :index?, record: :annotations }
    )
  end
end
