# frozen_string_literal: true

module Components
  class UserMenu < Base
    def initialize(user:, **user_attrs)
      @user = user

      super(**user_attrs)
    end

    def view_template
      DropdownMenu(options: { placement: 'bottom-end' }) do
        DropdownMenuTrigger(class: 'w-full') do
          Button(variant: :ghost, class: "flex items-center space-x-2") do
            div do
              UserAvatar(user: @user)
            end

            span(class: "text-gray-800 dark:text-white") { @user.display_name }
          end
        end

        DropdownMenuContent do
          DropdownMenuLabel { "My Account" }
          DropdownMenuSeparator
          DropdownMenuItem(href: user_path(@user)) do
            icon("user-round")
            plain "Profile"
          end

          DropdownMenuItem(href: session_path, data_turbo_method: :delete) do
            icon("log-out")
            plain "Logout"
          end
        end
      end
    end
  end
end
