# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Renders the roles settings page.
      #
      # Roles are grouped by origin. The engine ships Admin and Read all,
      # which have no editable permission list, and the rest are defined by
      # this catalog.
      class Index < Views::Base
        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param overview [Junction::Roles::Overview] Every role, and what each
        #   one reaches.
        # @param can_create [Boolean] Whether the user may add a role.
        # @param open [String] Pane id of the role that opens with the page;
        #   defaults to the first row in the list.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(overview:, can_create: true, open: nil, breadcrumbs: [])
          @overview = overview
          @can_create = can_create
          @open = open
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            SettingsPage(title: t(".title"), description: t(".description"),
                         action: new_role_action) do |page|
              page.callout(variant: :info) { t(".granting_note") }

              roles = @overview.roles
              next empty_state if roles.empty?

              page.panes(default: open_pane) do |panes|
                index_pane(panes)
                roles.each { |role| detail_pane(panes, role) }
              end
            end
          end
        end

        private

        # Returns the pane that opens with the page.
        #
        # The list draws system roles above custom ones, so the first row isn't
        # necessarily the first role by title.
        #
        # @return [String] The pane id.
        def open_pane
          @open || (@overview.system_roles.first || @overview.custom_roles.first).id
        end

        # Builds the header's New role action, for a user who may add roles.
        #
        # @return [Hash, nil] The action, or nil when the user may not.
        def new_role_action
          return unless @can_create

          { label: t(".new"), href: new_role_path }
        end

        # Renders the index pane.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def index_pane(panes)
          panes.index do |index|
            index.list do |list|
              role_group(list, t(".system_roles"), @overview.system_roles)
              role_group(list, t(".custom_roles"), @overview.custom_roles)
            end

            index.footnote { registry_note }
          end
        end

        # Renders one group of roles, unless the group is empty.
        #
        # @param list [Components::Settings::SettingsIndexList] The rows.
        # @param label [String] The group's heading.
        # @param roles [Array<Junction::Roles::Overview::Summary>] Its roles.
        def role_group(list, label, roles)
          return if roles.empty?

          list.group(label) do |group|
            roles.each do |role|
              group.item(value: role.id, label: role.title, mono: false,
                         sublabel: reach(role))
            end
          end
        end

        # Summarizes a role as its permission count and the number of groups
        # holding it.
        #
        # @param role [Junction::Roles::Overview::Summary] The role.
        # @return [String] The summary of the role.
        def reach(role)
          [ t(".permission_count", count: role.permissions),
            t(".group_count", count: role.groups) ].join("  ·  ")
        end

        # Returns the footnote.
        #
        # @return [String] The note.
        def registry_note
          plugins = @overview.plugins_registering
          registered = t(".permission_count",
                         count: @overview.registered_permissions.size)

          [
            t(".role_count", count: @overview.roles.size),
            if plugins.positive?
              t(".registered_with_plugins", permissions: registered,
                                            plugins: t(".plugin_count", count: plugins))
            else
              t(".registered_by_engine", permissions: registered)
            end
          ].join("  ·  ")
        end

        # Renders one role's detail pane, loaded on demand so opening the
        # page doesn't build every role's permission matrix.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        # @param role [Junction::Roles::Overview::Summary] The role.
        def detail_pane(panes, role)
          panes.detail(value: role.id, frame: "role_#{role.id}",
                       src: junction_catalog_path(role.record))
        end

        # Renders a message when no roles exist, which happens before the
        # seeds have run.
        def empty_state
          p(class: "text-sm text-text-tertiary") { t(".empty") }
        end
      end
    end
  end
end
