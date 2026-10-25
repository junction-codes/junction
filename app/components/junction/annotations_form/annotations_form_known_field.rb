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
          Text(
            @annotations_form,
            @annotation[:key],
            label: @annotation[:title],
            label_action: method(:annotation_key),
            placeholder: @annotation[:placeholder]
          )
        end

        private

        # Renders the annotation's key.
        def annotation_key
          span(class: "font-mono text-[11.5px] text-text-tertiary") do
            @annotation[:key]
          end
        end
      end
    end
  end
end
