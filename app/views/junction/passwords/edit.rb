# frozen_string_literal: true

module Junction
  module Views
    module Passwords
      # Renders the reset password page.
      #
      # This page must be accessed via the link sent in the password reset
      # email. To change the password for a signed-in user, see {User::Edit}.
      class Edit < Views::Base
        # Initializes the view.
        #
        # @param token [String] The single-use token from the emailed link.
        def initialize(token:)
          @token = token
        end

        def view_template
          render Layouts::Unauthenticated.new do
            AuthCard(heading: t(".reset"), description: t(".description")) do
              AuthNotice(variant: :alert, message: flash[:alert]) if flash[:alert].present?

              form_with(url: password_path(@token), method: :put,
                        class: "space-y-5") do |form|
                Password(form, :password, label: t(".password"),
                                          placeholder: "••••••••",
                                          required: true, autofocus: true,
                                          autocomplete: "new-password",
                                          class: "h-11")

                Password(form, :password_confirmation,
                         label: t(".password_confirmation"),
                         placeholder: "••••••••", required: true,
                         autocomplete: "new-password", class: "h-11")

                Button(type: "submit", variant: :primary,
                       class: "h-11 w-full justify-center",
                       data: { turbo_submits_with: t(".submitting") }) { t(".submit") }
              end

              p(class: "mt-6 text-center") do
                AuthLink(href: new_session_path) { t(".back") }
              end
            end
          end
        end
      end
    end
  end
end
