# frozen_string_literal: true

module Junction
  module Components
    module AnnotationsForm
      # Renders an annotations form for a single entity.
      class AnnotationsForm < Base
        # Initializes a new component.
        #
        # @param form [ActionView::Helpers::FormBuilder] Form builder.
        # @param context [ApplicationRecord] The entity to render the form for.
        def initialize(form:, context:)
          @form = form
          @context = context
        end

        def view_template
          Card do |card|
            card.header do |header|
              header.title { t(".title") }
              header.description { t(".description") }
            end

            card.content(class: "space-y-6") do
              AnnotationsFormKnownSection(
                form: @form,
                context: @context,
                known_annotations:
              ) if known_annotations.any?

              AnnotationsFormOtherSection(form: @form, context: @context)
            end
          end
        end

        private

        # Retrieves the known annotations for the entity's type.
        #
        # @return [Hash<String, Hash>] Definitions for known annotations.
        def known_annotations
          @known_annotations ||= PluginRegistry.annotations_for(@context.class)
        end

        def t(key, options = {})
          return super(key, **options) unless key[0] == "."

          I18n.t(key, **options.merge(scope: "junction.components.annotations_form"))
        end
      end
    end
  end
end
