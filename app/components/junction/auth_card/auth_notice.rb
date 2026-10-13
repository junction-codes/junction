# frozen_string_literal: true

module Junction
  module Components
    module AuthCard
      # Renders a notice for an unauthenticated form after a submission
      # attempt.
      class AuthNotice < Base
        # Available variants for the notice.
        VARIANTS = {
          alert: { class: "bg-alert-subtle text-alert border-alert",
                   icon: "triangle-alert", role: "alert" },
          success: { class: "bg-success-subtle text-success border-success",
                     icon: "circle-check", role: "status" }
        }.freeze

        # Initializes the component.
        #
        # @param variant [Symbol] One of {VARIANTS}.
        # @param message [String] Message to display to the user.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(variant:, message:, **user_attrs)
          @variant = VARIANTS.fetch(variant)
          @message = message

          super(**user_attrs)
        end

        def view_template
          div(role: @variant[:role], **attrs) do
            icon(@variant[:icon], class: "mt-px h-4 w-4 shrink-0")
            span { @message }
          end
        end

        private

        def default_attrs
          { class: "mb-5 flex items-start gap-3 rounded-md border-l-[3px] " \
                   "px-4 py-3 text-[13px] leading-5 #{@variant[:class]}" }
        end
      end
    end
  end
end
