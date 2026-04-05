# frozen_string_literal: true

module Junction
  module Components
    # Renders an auto-generated slug identifier field for entity forms.
    #
    # On a new record the identifier is generated as the user types (auto mode).
    # The field's value is derived from the form field specified by the `source`
    # parameter. A link allows switching to manual mode.
    #
    # In manual mode, the slug can be edited directly. There is no
    # auto-generation in this mode. A link allows switching to auto mode, which
    # regenerates the slug from the source field.
    #
    # On a persisted record the identifier is shown read-only with a tooltip,
    # and a hidden input preserves the value for form submission.
    class SlugField < FieldType
      CODE_CLASS = "font-mono text-sm text-gray-700 dark:text-gray-300 " \
                   "bg-gray-100 dark:bg-gray-700 rounded px-2 py-1 " \
                   "cursor-default"

      INPUT_CLASS = "block w-full rounded-md border-0 py-1.5 text-gray-900 " \
                    "shadow-sm ring-1 ring-inset ring-gray-300 " \
                    "placeholder:text-gray-400 focus:ring-2 focus:ring-inset " \
                    "focus:ring-blue-600 sm:text-sm sm:leading-6 " \
                    "dark:bg-gray-700 dark:text-white dark:ring-gray-600 " \
                    "dark:focus:ring-blue-500"

      LABEL_CLASS = "block text-sm font-medium leading-6 text-gray-900 " \
                    "dark:text-white"


      # Initializes a new field component.
      #
      # @param form [ActionView::Helpers::FormBuilder] The form builder.
      # @param method [Symbol] Method name for the field.
      # @param label [String] Optional, human-readable label for the field.
      # @param help_text [String] Optional help text for the field.
      # @param placeholder [String] Optional placeholder text for the field.
      # @param required [Boolean] Whether the field is required.
      # @param source [Symbol] Method name for the field whose input drives
      #   auto-generation.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(form, method, label: nil, help_text: nil, required: false,
                     source: :title, **user_attrs)
        @source = source

        super(form, method, label:, help_text:, required:, **user_attrs)
      end

      def view_template
        div(data: {
            controller: "slug-field",
            slug_field_persisted_value: persisted?.to_s,
            slug_field_source_selector_value: "input[name$='[#{@source}]']"
          }, **attrs) do
          div do
            div(class: "flex items-center justify-between") do
              span(class: LABEL_CLASS) do
                plain label
                span(class: "text-red-500 ml-1") { " *" } if @required && !persisted?
              end

              render_mode_switcher unless persisted?
            end

            div(class: "mt-2") do
              persisted? ? render_read_only : render_editable
            end

            p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

            if errors.any?
              div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
                errors.each { |e| p { "#{label} #{e}" } }
              end
            end
          end
        end
      end

      private

      # Render the field in read-only mode.
      def render_read_only
        Tooltip do |tooltip|
          tooltip.trigger do
            code(class: CODE_CLASS) do
              plain @form.object.public_send(@method)
              span(class: "sr-only") { t(".immutable", label: label) }
            end
          end

          tooltip.content { t(".immutable", label: label) }
        end

        @form.hidden_field @method
      end

      # Render the field in editable mode.
      def render_editable
        div(data: { slug_field_target: "slugDisplayWrapper" }) do
          code(
            class: "font-mono text-sm text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded px-2 py-1 inline-block min-w-16",
            data: { slug_field_target: "slugDisplay" }
          ) { @form.object.public_send(@method).presence || "auto-generated" }
          @form.hidden_field @method, data: { slug_field_target: "slugInput" }
        end

        div(
          class: "hidden",
          data: { slug_field_target: "slugInputWrapper" }
        ) do
          @form.text_field @method,
            class: INPUT_CLASS,
            name: nil,
            data: {
              slug_field_target: "slugManualInput",
              action: "input->slug-field#onManualSlugInput"
            }
        end
      end

      def render_mode_switcher
        div(class: "flex gap-2 text-xs") do
          a(
            href: "#",
            class: "hidden text-blue-500 hover:underline",
            data: {
              slug_field_target: "autoLink",
              action: "click->slug-field#enableAutoMode"
            }
          ) { t(".auto") }

          a(
            href: "#",
            class: "text-blue-500 hover:underline",
            data: {
              slug_field_target: "editLink",
              action: "click->slug-field#enableEditMode"
            }
          ) { t(".edit") }
        end
      end
    end
  end
end
