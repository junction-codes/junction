# frozen_string_literal: true

module Junction
  module Components
    # Renders a field that is editable on creation but read-only thereafter.
    #
    # On a new record the field renders as a standard text input.
    #
    # On a persisted record the current value is shown as styled code text
    # behind a tooltip that explains why the field cannot be edited. A hidden
    # input preserves the value for form submission.
    class ImmutableField < Base
      LABEL_CLASS = "block text-sm font-medium leading-6 text-gray-900 dark:text-white"
      INPUT_CLASS = "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:focus:ring-blue-500"
      CODE_CLASS = "font-mono text-sm text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded px-2 py-1 cursor-default"

      # Initializes a new component.
      #
      # @param form [ActionView::Helpers::FormBuilder] The form builder.
      # @param method [Symbol] Method name for the field.
      # @param label [String] Human-readable label for the field.
      # @param placeholder [String] Placeholder text for the editable input.
      # @param help_text [String] Optional help text shown below the field when
      #   editable.
      # @param required [Boolean] Whether the field is required.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(form, method, label, placeholder: nil, help_text: nil,
                     required: false, **user_attrs)
        @form = form
        @method = method
        @label = label
        @placeholder = placeholder
        @help_text = help_text
        @required = required

        super(**user_attrs)
      end

      def view_template
        div(**attrs) do
          @form.label @method, class: LABEL_CLASS do
            plain @label
            span(class: "text-red-500 ml-1") { " *" } if @required && !persisted?
          end

          div(class: "mt-2") do
            if persisted?
              Tooltip do |tooltip|
                tooltip.trigger do
                  code(class: CODE_CLASS) do
                    plain @form.object.public_send(@method)
                    span(class: "sr-only") { t(".immutable", label: @label) }
                  end
                end

                tooltip.content { t(".immutable", label: @label) }
              end

              @form.hidden_field @method
            else
              @form.text_field @method,
                class: INPUT_CLASS,
                placeholder: @placeholder
            end
          end

          p(class: "mt-1 text-xs text-gray-500") { @help_text } if @help_text && !persisted?

          if @form.object.errors[@method].any?
            div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
              @form.object.errors[@method].each { |e| p { "#{@label} #{e}" } }
            end
          end
        end
      end

      private

      def persisted?
        @form.object.persisted?
      end
    end
  end
end
