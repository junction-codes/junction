# frozen_string_literal: true

module Junction
  module Views
    module Passwords
      # Edit view for passwords.
      class Edit < Views::Base
        def initialize(token:)
          @token = token
        end

        def view_template
          render Layouts::Unauthenticated.new do
            template
          end
        end

        def template
          section(class: "bg-gray-50 dark:bg-gray-900") do
            div(class: "flex flex-col items-center justify-center px-6 py-8 mx-auto md:h-screen lg:py-0") do
              a(href: "#", class: "flex items-center mb-6 text-2xl font-semibold text-gray-900 dark:text-white") do
                icon("square-dashed-bottom-code", class: "w-8 h-8 mr-2")
                plain t("app.title")
              end

              div(class: "w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-md xl:p-0 dark:bg-gray-800 dark:border-gray-700") do
                div(class: "p-6 space-y-4 md:space-y-6 sm:p-8") do
                  h1(class: "text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white") do
                    plain("Reset your password")
                  end

                  form_with(url: password_path(@token), class: "space-y-4 md:space-y-6", method: :put) do |form|
                    PasswordField(form, :password, "Enter new password", placeholder: "••••••••", required: true, autofocus: true, autocomplete: "new-password")
                    PasswordField(form, :password_confirmation, "Repeat new password", placeholder: "••••••••", required: true, autofocus: true, autocomplete: "new-password")

                    div(class: "flex items-center justify-between") do
                      a(href: new_session_path, class: "text-sm font-medium text-primary-600 hover:underline dark:text-primary-500") { plain("Back to log in") }
                    end

                    if flash[:alert].present?
                      div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "password_errors") do
                          p { flash[:alert] }
                      end
                    end

                    div(class: "flex justify-between items-center") do
                      Button(type: "submit", variant: :primary, data: { form_target: "submit" }, class: "w-full") do
                        plain "Reset password"
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
