# frozen_string_literal: true

module Junction
  module Views
    module Passwords
      # Renders the forgotten password page.
      #
      # This same page is used both for the request form and the confirmation.
      class New < Views::Base
        # Initializes the view.
        #
        # @param sent_to [String] Email address a link was just requested for,
        #   if one has been requested.
        def initialize(sent_to: nil)
          @sent_to = sent_to
        end

        def view_template
          render Layouts::Unauthenticated.new do
            @sent_to.present? ? confirmation : request_form
          end
        end

        private

        # Renders the password reset request form.
        def request_form
          AuthCard(heading: t(".request"), description: t(".expires")) do
            AuthNotice(variant: :alert, message: flash[:alert]) if flash[:alert].present?

            form_with(url: passwords_path, class: "space-y-5") do |form|
              Text(form, :email, label: t(".email"), type: "email",
                                 placeholder: t(".email_placeholder"),
                                 autofocus: true, autocomplete: "username",
                                 class: "h-11")

              Button(type: "submit", variant: :primary,
                     class: "h-11 w-full justify-center",
                     data: { turbo_submits_with: t(".submitting") }) { t(".submit") }
            end

            p(class: "mt-6 text-center") { back_link }
          end
        end

        # Renders the confirmation message given after the form is submitted.
        def confirmation
          AuthCard do
            div(class: "flex flex-col items-center text-center") do
              div(class: "mb-5 flex h-11 w-11 items-center justify-center " \
                         "rounded-xl bg-success-subtle") do
                icon("shield-check", class: "h-[22px] w-[22px] text-success")
              end

              h1(class: "text-[17px] font-semibold text-foreground") do
                t(".sent_heading")
              end

              p(class: "mt-3 text-[13px] leading-6 text-text-tertiary") do
                t(".sent_body", email: @sent_to)
              end

              Link(href: new_session_path, variant: :outline,
                   class: "mt-6 w-full justify-center") { t(".back") }
            end
          end
        end

        # Renders the back link.
        def back_link
          AuthLink(href: new_session_path) { t(".back") }
        end
      end
    end
  end
end
