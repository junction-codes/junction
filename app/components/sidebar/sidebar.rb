# frozen_string_literal: true

module Components
  class Sidebar < Base
    include PluginDispatchHelper

    def view_template
      aside(
        data_sidebar_target: "sidebar",
        class: "bg-white dark:bg-gray-800 flex flex-col transition-all duration-300 w-64"
      ) do
        nav(class: "flex-1 px-2 py-4 space-y-2") do
          item(href: "#", icon: "house", title: "Dashboard", disabled: true)
          item(href: "#{domains_path}", icon: "briefcase", title: "Domains")
          item(href: "#{systems_path}", icon: "network", title: "Systems")
          item(href: "#{components_path}", icon: "server", title: "Components")
          item(href: "#{apis_path}", icon: "webhook", title: "APIs")
          item(href: "#{deployments_path}", icon: "rocket", title: "Deployments")
          item(href: "#{resources_path}", icon: "rows-4", title: "Resources")
          item(href: "#{groups_path}", icon: "users-round", title: "Groups")
          item(href: "#{users_path}", icon: "user-round", title: "Users")
          item(href: "#", icon: "book-open", title: "TechDocs", disabled: true)
          item(href: "#", icon: "dollar-sign", title: "Cost Explorer", disabled: true)

          render_sidebar_links(self)
        end

        footer(class: "p-4 border-t border-gray-200 dark:border-gray-700") do
          p(data_sidebar_target: "linkText", class: "text-xs text-gray-400") { "© #{Time.now.year} Developer Org" }
        end
      end
    end

    def item(*, **, &)
      render SidebarItem(*, **, &)
    end
  end
end
