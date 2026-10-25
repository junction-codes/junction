# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Renders a field that is editable on creation but read-only thereafter.
      #
      # On a new record the field renders as a standard text input.
      #
      # On a persisted record the current value is shown as styled code text
      # behind a tooltip that explains why the field cannot be edited. A hidden
      # input preserves the value for form submission.
      class Immutable < FieldType
        CODE_CLASSES = %w[
          font-mono
          text-sm
          text-text-body
          bg-subtle
          rounded
          px-2
          py-1
          cursor-default
        ].freeze


        def view_template
          div(**attrs) do
            render_label

            div(class: "mt-2") do
              if persisted?
                Tooltip do |tooltip|
                  tooltip.trigger do
                    code(class: CODE_CLASSES) do
                      plain @form.object.public_send(@method)
                      span(class: "sr-only") { t(".immutable", label: label_text) }
                    end
                  end

                  tooltip.content { t(".immutable", label: label_text) }
                end

                @form.hidden_field @method
              else
                @form.text_field @method, class: Text::BASE_CLASSES, placeholder:
              end
            end

            p(class: HELP_CLASSES) { @help_text } if @help_text && !persisted?

            if errors.any?
              div(class: "mt-2 text-sm text-destructive", id: "#{@method}_errors") do
                errors.each { |e| p { "#{label_text} #{e}" } }
              end
            end
          end
        end
      end
    end
  end
end
