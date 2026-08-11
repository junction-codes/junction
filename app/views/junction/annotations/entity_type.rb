# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Lazy-loaded panel for a single entity type.
      class EntityType < Views::Base
        # Initializes the view.
        #
        # @param panel [Hash] The annotation entity type panel data.
        def initialize(panel:)
          @panel = panel
        end

        def view_template
          turbo_frame_tag "annotation_entity_type_#{@panel.fetch(:id)}" do
            AnnotationEntityTypePanel(panel: @panel)
          end
        end
      end
    end
  end
end
