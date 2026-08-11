# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders the header of an entity type annotations panel.
      class AnnotationEntityTypePanelHeader < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_entity_type_panel_header"
        end

        # Initializes a new component.
        #
        # @param panel [Hash] The annotation panel data.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(panel:, **user_attrs)
          @panel = panel

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            h3(class: "text-lg font-semibold text-gray-900 dark:text-gray-100") do
              panel.fetch(:label)
            end

            p(class: "text-sm text-gray-500 dark:text-gray-400") do
              t(".records_total", count: panel.fetch(:total_count))
            end
          end
        end

        private

        def default_attrs
          {
            class: "space-y-1"
          }
        end
      end
    end
  end
end
