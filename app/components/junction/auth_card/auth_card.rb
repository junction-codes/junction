# frozen_string_literal: true

module Junction
  module Components
    module AuthCard
      # Renders the card used for every unauthenticated page.
      #
      # Signing in, asking for a reset link, and setting a new password all
      # share this shell. This ensures a consistent experience for
      # unauthenticated users.
      #
      # The backdrop stays dark in both themes while the card follows the
      # theme.
      #
      # @example Signing in.
      #   AuthCard(heading: t(".sign_in_heading")) { form }
      class AuthCard < Base
        # Initializes the component.
        #
        # @param heading [String] The heading at the top of the card; omitted
        #   by a card that builds its own header.
        # @param description [String] Description displayed as a subheading.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(heading: nil, description: nil, **user_attrs)
          @heading = heading
          @description = description

          super(**user_attrs)
        end

        def view_template(&block)
          div(**attrs) do
            glows

            div(class: "relative z-10 w-full max-w-[440px] py-10") do
              masthead
              card(&block)
              demo_notice
              footer
            end
          end
        end

        private

        def default_attrs
          { class: "relative flex min-h-screen items-center justify-center " \
                   "overflow-hidden bg-auth-backdrop px-6" }
        end

        # Renders the two pools of color behind the card.
        def glows
          div(aria_hidden: "true",
              class: "pointer-events-none absolute -top-[260px] left-1/2 " \
                     "h-[800px] w-[800px] -translate-x-1/4 rounded-full " \
                     "bg-auth-glow opacity-25 blur-[160px]")

          div(aria_hidden: "true",
              class: "pointer-events-none absolute -bottom-[120px] left-0 " \
                     "h-[620px] w-[620px] -translate-x-1/3 rounded-full " \
                     "bg-auth-glow-deep opacity-30 blur-[150px]")
        end

        # Renders the application masthead above the card.
        #
        # This includes the application logo, name, and the organization name if
        # present.
        def masthead
          div(class: "mb-8 flex flex-col items-center gap-3") do
            div(class: "flex items-center gap-3") do
              div(class: "flex h-10 w-10 items-center justify-center " \
                         "rounded-xl bg-accent-solid") do
                Logo(class: "h-6 w-6 text-white")
              end

              span(class: "text-xl font-bold text-white") { t("app.title") }
            end

            if organization_name.present?
              span(class: "text-[13px] text-white/70") { organization_name }
            end
          end
        end

        # Renders the card itself.
        def card(&block)
          div(class: "rounded-2xl border border-border bg-surface p-10 shadow-xl") do
            if @heading.present?
              h1(class: "text-2xl font-bold tracking-tight text-foreground") do
                @heading
              end
            end

            if @description.present?
              p(class: "mt-2 text-[13px] leading-5 text-text-tertiary") do
                @description
              end
            end

            div(class: ("mt-6" if @heading.present?), &block)
          end
        end

        # Renders the demo notice when in demo mode.
        def demo_notice
          return unless Junction.config.allow_demo_mode

          div(class: "mt-6 flex items-start gap-3 rounded-[10px] " \
                     "bg-info-subtle px-5 py-4 text-[12px] font-medium " \
                     "leading-5 text-info") do
            icon("info", class: "mt-px h-[18px] w-[18px] shrink-0")
            span { t(".demo") }
          end
        end

        # Renders the footer with help information.
        def footer
          p(class: "mt-8 text-center text-[12px] text-white/50") { t(".help") }
        end

        # Returns the organization that owns the catalog, if defined.
        #
        # @return [String, nil] The name, when one is configured.
        def organization_name
          Junction.config.organization_name
        end
      end
    end
  end
end
