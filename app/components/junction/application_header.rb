# frozen_string_literal: true

module Junction
  module Components
    class ApplicationHeader < Base
      def initialize(user: Junction::Current.user, **user_attrs)
        @user = user

        super
      end

      def view_template
        header(class: "bg-white dark:bg-gray-800 shadow-sm p-4 flex justify-between items-center border-b border-gray-200 dark:border-gray-700") do
          div(class: "flex items-center space-x-4") do
            button(data_action: "click->sidebar#toggle", class: "cursor-pointer text-gray-500 dark:text-gray-400 focus:outline-none") do
            icon("menu", class: "w-6 h-6")
            end

            h1(class: "text-xl font-semibold text-gray-800 dark:text-white whitespace-nowrap inline-flex items-center justify-center") do
              icon(Junction.config.icon, class: "h-8 w-8 pe-2")
              plain t("app.title")
            end
          end

          render SearchBar.new

          # User preferences and menus.
          div(class: "flex items-center space-x-4") do
            ThemeToggle()

            button(class: "text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-white") { icon("bell", class: "w-6 h-6") }

            div(class: "relative") do
              UserMenu(user: @user)
            end
          end
        end
      end
    end
  end
end
