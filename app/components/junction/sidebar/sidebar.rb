# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      class Sidebar < Base
        include PluginDispatchHelper

        # Kinds shown in the main navigation, in display order. Only the order
        # lives here; the icon, path, and title come from the kind registry.
        NAV_SCOPES = %i[domain system component api resource group user].freeze

        def view_template
          div(
            data_sidebar_target: "sidebar",
            class: "relative z-20 bg-white dark:bg-gray-800 flex flex-col transition-all duration-300 w-64"
          ) do
            nav(aria_label: t(".navigation"),
                class: "flex-1 flex flex-col gap-2") do
              div(class: "space-y-2 px-2 py-4") do
                item(href: view_context.dashboard_path, icon: "house", title: t(".dashboard")) if allowed_to?(:show?, :dashboard)

                nav_kinds.each do |kind|
                  item(
                    href: view_context.public_send(:"#{kind.plural}_path"),
                    icon: kind.default_icon,
                    title: kind.model.model_name.human(count: 2),
                    count: counts[kind.name]
                  )
                end

                # TODO: Implement techdocs and cost explorer.
                item(href: "#", icon: "book-open", title: t(".techdocs"), disabled: true)
                item(href: "#", icon: "dollar-sign", title: t(".cost_explorer"), disabled: true)

                render_sidebar_links(self)
              end

              settings_menu_items = plugin_settings_menu_items
              if settings_menu_items.any?
                SettingsMenu(
                  items: settings_menu_items,
                  title: t(".settings")
                )
              end
            end

            footer(class: "p-4 border-t border-gray-200 dark:border-gray-700") do
              p(data_sidebar_target: "linkText", class: "text-xs text-gray-500 dark:text-gray-400") { t(".footer") }
            end
          end
        end

        def item(...)
          render SidebarItem.new(...)
        end

        private

        # Kinds the current user may list, in display order.
        #
        # @return [Array<Junction::Kind>] The kinds.
        def nav_kinds
          @nav_kinds ||= NAV_SCOPES
            .filter_map { |scope| Junction::Kinds.by_scope(scope) }
            .select { |kind| allowed_to?(:index?, kind.model) }
        end

        # How many entities of each kind the user may read.
        #
        # Scoped the same way the listings are, so the number beside a link
        # matches what opening it shows. Computed once per request.
        #
        # @return [Hash{String => Integer}] Counts keyed by kind name.
        def counts
          Junction::ReadableEntities.current.counts(nav_kinds)
        end
      end
    end
  end
end
