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
            label(for: key_id, class: Field::FieldType::LABEL_CLASSES) do
              t(".name")
            end
            div(class: "mt-2") do
              input(
                type: "text",
                id: key_id,
                name: @key_name,
                value: @key_value,
                class: Field::Text::BASE_CLASSES
              )
            end
          end

          div do
            label(for: value_id, class: Field::FieldType::LABEL_CLASSES) do
              t(".value")
            end
            div(class: "mt-2") do
              input(
                type: "text",
                id: value_id,
                name: @value_name,
                value: @value_value,
                class: Field::Text::BASE_CLASSES
              )
            end
          end
        end

        private

        # ID for the annotation key field.
        #
        # @return [String] HTML ID for the key field.
        def key_id
          @key_id ||= "annotation_key_#{object_id}_#{@key_name.hash.abs}"
        end

        # ID for the annotation value field.
        #
        # @return [String] HTML ID for the value field.
        def value_id
          @value_id ||= "annotation_value_#{object_id}_#{@value_name.hash.abs}"
        end

        def t(key, options = {})
          return super(key, **options) unless key[0] == "."

          I18n.t(key, **options.merge(scope: "junction.components.annotations_form"))
        end
      end
    end
  end
end
