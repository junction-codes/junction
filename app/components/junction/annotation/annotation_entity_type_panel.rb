# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders an annotations panel for a single entity type.
      class AnnotationEntityTypePanel < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_entity_type_panel"
        end

        # Initializes a new component.
        #
        # @param panel [Hash] The annotation entity type panel data.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(panel:, **user_attrs)
          @panel = panel

          super(**user_attrs)
        end

        def view_template
          section(**attrs) do
            AnnotationEntityTypePanelHeader(panel:)
            AnnotationEntityTypePanelCharts(panel:)
            AnnotationEntityTypePanelTable(
              items: panel.fetch(:known),
              title: t(".known"),
              empty_message: t(".empty_known")
            )
            AnnotationEntityTypePanelTable(
              items: panel.fetch(:other),
              title: t(".other"),
              empty_message: t(".empty_other")
            )
          end
        end

        private

        def default_attrs
          {
            class: "space-y-6"
          }
        end
      end
    end
  end
end
