# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for entering a password.
      class Password < FieldType
        def view_template
          div do
            render_label

            div(class: "mt-2") do
              @form.password_field @method, placeholder:, **attrs
            end

            p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

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
            class: Text::BASE_CLASSES,
            required: @required
          }
        end
      end
    end
  end
end
