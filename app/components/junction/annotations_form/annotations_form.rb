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
        # @param framed [Boolean] Whether to draw its own card.
        def initialize(form:, context:, framed: true)
          @form = form
          @context = context
          @framed = framed
        end

        def view_template
          return sections unless @framed

          Card do |card|
            card.header do |header|
              header.title { t(".title") }
              header.description { t(".description") }
            end

            card.content(class: "space-y-6") { sections }
          end
        end

        private

        # The editor itself, whether or not it's in a card of its own.
        def sections
          div(class: "space-y-6") do
            secret_warning

            if known_annotations.any?
              AnnotationsFormKnownSection(form: @form, context: @context,
                                          known_annotations:)
            end

            AnnotationsFormOtherSection(form: @form, context: @context)
          end
        end

        # Warns that annotations are not a suitable place for secrets.
        def secret_warning
          Alert(variant: :warning, dismissible: false) do |alert|
            alert.description { t(".secret_warning") }
          end
        end

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
