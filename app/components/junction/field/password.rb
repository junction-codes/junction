# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for entering a password.
      #
      # The input field allows the user to toggle the visibility of the
      # password.
      class Password < FieldType
        def view_template
          div(data: { controller: "password-visibility" }) do
            render_label

            div(class: "relative mt-2") do
              @form.password_field @method, placeholder:, **attrs
              reveal_button
            end

            p(class: HELP_CLASSES) { @help_text } if @help_text

            render_errors
          end
        end

        private

        def default_attrs
          {
            class: [ *Text::BASE_CLASSES, "pr-10" ],
            required: @required,
            data: { password_visibility_target: "input" }
          }
        end

        # Renders the control that swaps the field between redacted and text.
        def reveal_button
          button(type: "button", aria_label: t(".reveal"), aria_pressed: "false",
                 class: "absolute right-3 top-1/2 -translate-y-1/2 " \
                        "text-text-tertiary hover:text-text-body " \
                        "focus:outline-none focus-visible:ring-2 " \
                        "focus-visible:ring-ring rounded",
                 data: { action: "password-visibility#toggle",
                         password_visibility_target: "button" }) do
            icon("eye", class: "h-[18px] w-[18px]",
                        data: { password_visibility_target: "revealIcon" })
            icon("eye-off", class: "h-[18px] w-[18px] hidden",
                            data: { password_visibility_target: "hideIcon" })
          end
        end
      end
    end
  end
end
