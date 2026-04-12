# frozen_string_literal: true

module Junction
  module Components
    module Users
      class UserMenu < Base
        def initialize(user:, **user_attrs)
          @user = user

          super(**user_attrs)
        end

        def view_template
          DropdownMenu(options: { placement: "bottom-end" }) do |menu|
            menu.trigger(class: "w-full") do |trigger|
              trigger.button(variant: :ghost, class: "flex items-center space-x-2") do
                div do
                  UserAvatar(user: @user)
                end

                span(class: "text-gray-800 dark:text-white") { @user.title }
              end
            end

            menu.content do |content|
              content.label { t(".account") }
              content.separator
              content.item(href: user_path(@user)) do
                icon("user-round")
                plain t(".profile")
              end

              content.item(href: session_path, data_turbo_method: :delete) do
                icon("log-out")
                plain t(".logout")
              end
            end
          end
        end
      end
    end
  end
end
