# frozen_string_literal: true

class Views::Sessions::New < Views::Base
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
              plain("Sign in to your account")
            end

            if flash[:success].present?
              div(class: "mt-2 text-sm text-success") do
                p { flash[:success] }
              end
            end

            form_with(url: session_url, class: "space-y-4 md:space-y-6", action: "#") do |form|
              Components::TextField(form, :email_address, "Your email", type: "email", placeholder: "example@example.com", autofocus: true, autocomplete: "username")
              Components::PasswordField(form, :password, "Password", placeholder: "••••••••", autocomplete: "current-password")

              div(class: "flex items-center justify-between") do
                a(href: new_password_path, class: "text-sm font-medium text-primary-600 hover:underline dark:text-primary-500") { plain("Forgot password?") }
              end

              if flash[:alert].present?
                div(class: "mt-2 text-sm text-alert") do
                    p { flash[:alert] }
                end
              end

              div(class: "flex justify-between items-center") do
                Button(type: "submit", variant: :primary, data: { form_target: "submit" }, class: "w-full") do
                  plain "Submit"
                end
              end
            end
          end
        end
      end
    end
  end
end
