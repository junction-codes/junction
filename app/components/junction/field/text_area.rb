# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for a multi-line text input.
      class TextArea < FieldType
        def view_template
          div do
            render_label

            div(class: "mt-2") do
              @form.text_area @method, placeholder:, **attrs
            end

            p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

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
