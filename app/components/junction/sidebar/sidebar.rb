# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      class Sidebar < Base
        include PluginDispatchHelper

        ENTITY_ICONS = {
          domains: "briefcase",
          systems: "network",
          components: "server",
          apis: "webhook",
          resources: "rows-4",
          groups: "users-round",
          users: "user-round",
          roles: "shield-check"
        }.freeze

        INDEX_PATH_BY_CONTEXT = {
          domains: :domains_path,
          systems: :systems_path,
          components: :components_path,
          apis: :apis_path,
          resources: :resources_path,
          groups: :groups_path,
          users: :users_path,
          roles: :roles_path
        }.freeze

        def view_template
          aside(
            data_sidebar_target: "sidebar",
            class: "bg-white dark:bg-gray-800 flex flex-col transition-all duration-300 w-64"
          ) do
            nav(class: "flex-1 px-2 py-4 space-y-2") do
              item(href: view_context.dashboard_path, icon: "house", title: t(".dashboard")) if allowed_to?(:show?, :dashboard)

              ENTITY_ICONS.each do |context, icon|
                path = INDEX_PATH_BY_CONTEXT.fetch(context)
                item(
                  href: view_context.public_send(path),
                  icon:,
                  title: Junction.const_get(context.to_s.classify).model_name.human(count: 2)
                ) if allowed_to?(:index?, context)
              end

              # TODO: Implement techdocs and cost explorer.
              item(href: "#", icon: "book-open", title: t(".techdocs"), disabled: true)
              item(href: "#", icon: "dollar-sign", title: t(".cost_explorer"), disabled: true)

              render_sidebar_links(self)
            end

            footer(class: "p-4 border-t border-gray-200 dark:border-gray-700") do
              p(data_sidebar_target: "linkText", class: "text-xs text-gray-400") { t(".footer") }
            end
          end
        end

        def item(...)
          render SidebarItem.new(...)
        end
      end
    end
  end
end
