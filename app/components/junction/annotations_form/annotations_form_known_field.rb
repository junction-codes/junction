# frozen_string_literal: true

module Junction
  module Components
    module AnnotationsForm
      # Renders a single known annotation field of an annotations form.
      class AnnotationsFormKnownField < Base
        # Initializes a new component.
        #
        # @param annotations_form [ActionView::Helpers::FormBuilder] Form
        #   builder for the annotations form.
        # @param annotation [Hash] Definition for the annotation.
        def initialize(annotations_form:, annotation:)
          @annotations_form = annotations_form
          @annotation = annotation
        end

        def view_template
          div do
            label(class: Field::FieldType::LABEL_CLASSES) do
              "#{@annotation[:title]} (#{@annotation[:key]})"
            end
            div(class: "mt-2") do
              @annotations_form.text_field(
                @annotation[:key],
                class: Field::Text::BASE_CLASSES,
                placeholder: @annotation[:placeholder]
              )
            end
          end
        end
      end
    end
  end
end
