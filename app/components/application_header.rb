# frozen_string_literal: true

module Components
  class ApplicationHeader < Base
    def initialize(**user_attrs)
      @user = Current.user

      super
    end

    def view_template
      header(class: "bg-white dark:bg-gray-800 shadow-sm p-4 flex justify-between items-center border-b border-gray-200 dark:border-gray-700") do
        div(class: "flex items-center space-x-4") do
          button(data_action: "click->sidebar#toggle", class: "cursor-pointer text-gray-500 dark:text-gray-400 focus:outline-none") do
           icon("menu", class: "w-6 h-6")
          end

          h1(class: "text-xl font-semibold text-gray-800 dark:text-white") { t("app.title") }
        end

        # Search bar.
        div(class: "relative") do
          input(type: "search", placeholder: "Search components, docs, etc.", class: "w-96 pl-10 pr-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500")
          span(class: "absolute left-3 top-1/2 -translate-y-1/2 text-gray-400") { icon("search", class: "w-5 h-5") }
        end

        # User preferences and menus.
        div(class: "flex items-center space-x-4") do
          render Components::ThemeToggle

          button(class: "text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-white") { icon("bell", class: "w-6 h-6") }

          div(class: "relative") do
            UserMenu(user: @user)
          end
        end
      end
    end
  end
end
