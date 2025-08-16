# frozen_string_literal: true

module Components
  class Sidebar < Base
    def view_template
      aside(
        data_sidebar_target: "sidebar",
        class: "bg-white dark:bg-gray-800 flex flex-col transition-all duration-300 w-64"
      ) do
        nav(class: "flex-1 px-2 py-4 space-y-2") do
          sidebar_link(href: "#", icon: "house", title: "Dashboard")
          sidebar_link(href: "#{domains_path}", icon: "briefcase", title: "Domains")
          sidebar_link(href: "#{systems_path}", icon: "network", title: "Systems")
          sidebar_link(href: "#{components_path}", icon: "server", title: "Components")
          sidebar_link(href: "#{deployments_path}", icon: "rocket", title: "Deployments")
          sidebar_link(href: "#{groups_path}", icon: "users-round", title: "Groups")
          sidebar_link(href: "#{users_path}", icon: "user-round", title: "Users")
          sidebar_link(href: "#", icon: "book-open", title: "TechDocs")
          sidebar_link(href: "#", icon: "dollar-sign", title: "Cost Explorer")
        end

        footer(class: "p-4 border-t border-gray-200 dark:border-gray-700") do
          p(data_sidebar_target: "linkText", class: "text-xs text-gray-400") { "© #{Time.now.year} Developer Org" }
        end
      end
    end

    private

    def sidebar_link(href:, icon:, title:)
      div do
        render Link.new(href: href, title:) do
          span(class: "flex-shrink-0") { icon(icon, class: "w-6 h-6") }
          span(data_sidebar_target: "linkText", class: "ml-4 whitespace-nowrap") { title }
        end
      end
    end
  end
end
