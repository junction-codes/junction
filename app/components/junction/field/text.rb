# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for a single-line text input.
      class Text < FieldType
        BASE_CLASSES = FieldType::INPUT_CLASSES

        def view_template
          div do
            render_label

            div(class: "mt-2") do
              @form.text_field @method, placeholder:, **attrs
            end

            p(class: HELP_CLASSES) { @help_text } if @help_text

            # If there are any validation errors, display them below the field
            if errors.any?
              div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
                errors.each do |error|
                  p { "#{label_text} #{error}" }
                end
              end
            end
          end
        end

        private

        def default_attrs
          {
            class: BASE_CLASSES,
            required: @required
          }
        end
      end
    end
  end
end
