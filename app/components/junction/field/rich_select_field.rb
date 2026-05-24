# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for selecting from a list of options with rich formatting.
      class RichSelectField < FieldType
        def self.translation_path
          "junction.components.field.rich_select"
        end

        # Initializes a new field component.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param method [Symbol] Method name for the field.
        # @param label [String] Optional, human-readable label for the field.
        # @param help_text [String] Optional help text for the field.
        # @param required [Boolean] Whether the field is required.
        # @param options [Hash] Selectable options keyed by stored value.
        # @param icon [String] Fallback icon for options without a custom icon.
        # @param allow_create [Boolean] Whether create-new UI is enabled.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(form, method, label: nil, help_text: nil, required: false,
                       options: {}, icon: "circle-small", allow_create: true,
                       **user_attrs)
          @options = options
          @icon = icon
          @allow_create = allow_create

          super(form, method, label:, help_text:, required:, **user_attrs)
        end

        def view_template
          div do
            render_label

            div(class: "mt-2") do
              render Junction::Components::RichSelect::RichSelect.new(
                value: @form.object.send(@method),
                input_id: @form.field_id(@method),
                input_name: @form.field_name(@method),
                options: @options,
                icon: @icon,
                allow_create: @allow_create,
                known_label: t(".known_group", label: label_text.pluralize),
                other_label: t(".other_group", label: label_text.pluralize),
                search_placeholder: t(".search_placeholder", label: label_text),
                no_results_text: t(".no_results"),
                blank_label: t(".blank", label: label_text),
                blank_description: placeholder,
                create_action: {
                  default_label: t(".create_blank_label"),
                  default_description: t(".create_hint", label: label_text),
                  selected_description: t(".create_selected_description")
                },
                **attrs
              )
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

        def placeholder
          @placeholder ||= t(".blank", label: label_text)
        end
      end
    end
  end
end
