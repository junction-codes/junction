# frozen_string_literal: true

module Junction
  module Components
    module AnnotationsForm
      # Renders the known annotations section of an annotations form.
      class AnnotationsFormKnownSection < Base
        # Initializes a new component.
        #
        # @param form [ActionView::Helpers::FormBuilder] Form builder.
        # @param context [ApplicationRecord] The entity to render the form for.
        # @param known_annotations [Hash<String, Hash>] Definitions for known
        #   annotations.
        def initialize(form:, context:, known_annotations:)
          @form = form
          @context = context
          @known_annotations = known_annotations
        end

        def view_template
          section(class: "space-y-4") do
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              t(".known")
            end

            @form.fields_for :annotations, @context.annotations do |annotations_form|
              @known_annotations.each_value do |annotation|
                AnnotationsFormKnownField(annotations_form:, annotation:)
              end
            end
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
