# frozen_string_literal: true

module Junction
  module Components
    module AnnotationsForm
      # Renders a single row of the other annotations section of an annotations form.
      class AnnotationsFormOtherRow < Base
        # Initializes a new component.
        #
        # @param key_name [String] HTML name of the key field.
        # @param value_name [String] HTML name of the value field.
        # @param key_value [String] Value of the key field.
        # @param value_value [String] Value of the value field.
        def initialize(key_name:, value_name:, key_value: nil, value_value: nil)
          @key_name = key_name
          @value_name = value_name
          @key_value = key_value
          @value_value = value_value
        end

        def view_template
          div do
            input(
              type: "text",
              name: @key_name,
              value: @key_value,
              aria: { label: t(".name") },
              class: Field::Text::BASE_CLASSES
            )
          end

          div do
            input(
              type: "text",
              name: @value_name,
              value: @value_value,
              aria: { label: t(".value") },
              class: Field::Text::BASE_CLASSES
            )
          end
        end

        private

        def t(key, options = {})
          return super(key, **options) unless key[0] == "."

          I18n.t(key, **options.merge(scope: "junction.components.annotations_form"))
        end
      end
    end
  end
end
