# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for a single-line text input.
      class Text < FieldType
        BASE_CLASSES = %w[
          block
          w-full
          rounded-md
          border-0
          py-1.5
          text-gray-900
          shadow-sm
          ring-1
          ring-inset
          ring-gray-300
          placeholder:text-gray-400
          focus:ring-2
          focus:ring-inset
          focus:ring-blue-600
          sm:text-sm
          sm:leading-6
          dark:bg-gray-700
          dark:text-white
          dark:ring-gray-600
          dark:focus:ring-blue-500
        ].freeze

        def view_template
          div do
            render_label

            div(class: "mt-2") do
              @form.text_field @method, placeholder:, **attrs
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
            class: BASE_CLASSES,
            required: @required
          }
        end
      end
    end
  end
end
