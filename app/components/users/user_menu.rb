# frozen_string_literal: true

module Components
  class UserMenu < Base
    def initialize(user:, **user_attrs)
      @user = user

      super(**user_attrs)
    end

    def view_template
      DropdownMenu(options: { placement: 'bottom-end' }) do |menu|
        menu.trigger(class: 'w-full') do |trigger|
          trigger.button(variant: :ghost, class: "flex items-center space-x-2") do
            div do
              UserAvatar(user: @user)
            end

            span(class: "text-gray-800 dark:text-white") { @user.display_name }
          end
        end

        menu.content do |content|
          content.label { "My Account" }
          content.separator
          content.item(href: user_path(@user)) do
            icon("user-round")
            plain "Profile"
          end

          content.item(href: session_path, data_turbo_method: :delete) do
            icon("log-out")
            plain "Logout"
          end
        end
      end
    end
  end
end
