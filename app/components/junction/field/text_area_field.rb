# frozen_string_literal: true

module Junction
  module Components
    # Form field for a multi-line text input.
    class TextAreaField < FieldType
      def view_template
        div do
          @form.label @method, class: "block text-sm font-medium leading-6 text-gray-900 dark:text-white" do
            plain label
            span(class: "text-red-500 ml-1") { " *" } if @required
          end

          div(class: "mt-2") do
            @form.text_area @method, **attrs
          end

          p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

          if errors.any?
            div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
              errors.each do |error|
                p { "#{label} #{error}" }
              end
            end
          end
        end
      end

      private

      def default_attrs
        {
          class: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:focus:ring-blue-500",
          required: @required
        }
      end
    end
  end
end
