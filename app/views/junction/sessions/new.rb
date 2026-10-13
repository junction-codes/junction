# frozen_string_literal: true

module Junction
  module Views
    module Sessions
      # Renders the sign-in page.
      class New < Views::Base
        include Phlex::Rails::Helpers::ButtonTo

        def view_template
          render Junction::Layouts::Unauthenticated do
            AuthCard(heading: t(".sign_in_heading"), description: t(".no_signup")) do
              notices
              sign_in_form
              provider_logins
            end
          end
        end

        private

        # Renders any notices from a previous sign-in attempt.
        def notices
          AuthNotice(variant: :success, message: flash[:success]) if flash[:success].present?
          AuthNotice(variant: :alert, message: flash[:alert]) if flash[:alert].present?
        end

        # Renders the basic authentication form.
        def sign_in_form
          form_with(url: session_url, class: "space-y-5") do |form|
            Text(form, :email, label: t(".email"), type: "email",
                               placeholder: t(".email_placeholder"),
                               autofocus: true, autocomplete: "username",
                               class: "h-11")

            Password(form, :password, label: t(".password"),
                                      placeholder: "••••••••",
                                      autocomplete: "current-password",
                                      label_action: forgot_link, class: "h-11")

            Button(type: "submit", variant: :primary,
                   class: "h-11 w-full justify-center",
                   data: { turbo_submits_with: t(".submitting") }) { t(".submit") }
          end
        end

        # Returns the forgotten password link.
        #
        # @return [Proc] The link.
        def forgot_link
          -> { AuthLink(href: new_password_path) { t(".forgot") } }
        end

        # Renders any provider login buttons.
        def provider_logins
          providers = Junction::PluginRegistry.auth_providers
          return if providers.empty?

          divider

          div(class: "space-y-3") do
            providers.each_value { |provider| provider_button(provider) }
          end
        end

        # Renders the divider between basic authentication and provider logins.
        def divider
          div(class: "my-6 flex items-center gap-4") do
            span(class: "h-px flex-1 bg-border")

            span(class: "text-[10.5px] font-semibold uppercase " \
                        "tracking-[0.12em] text-text-tertiary") do
              t(".continue_with")
            end

            span(class: "h-px flex-1 bg-border")
          end
        end

        # Renders one provider's button.
        #
        # @param provider [Hash] The provider, as the plugin registered it.
        def provider_button(provider)
          button_to("/auth/#{provider[:provider]}", method: :post,
                    data: { turbo: false },
                    class: "flex h-11 w-full cursor-pointer items-center " \
                           "justify-center gap-2.5 rounded-lg border " \
                           "border-border bg-surface text-[13.5px] " \
                           "font-medium text-text-body transition-colors " \
                           "hover:bg-subtle focus-visible:outline-none " \
                           "focus-visible:ring-2 focus-visible:ring-ring") do
            icon(provider[:icon], class: "h-[19px] w-[19px]",
                 fallback: Junction::ApplicationPlugin::DEFAULT_ICON)
            plain t(".continue_with_provider", provider: provider[:title])
          end
        end
      end
    end
  end
end
