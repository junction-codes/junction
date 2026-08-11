# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Lazy-loaded panel for a single annotation key.
      class AnnotationKey < Views::Base
        # Initializes the view.
        #
        # @param panel [Hash] The annotation key panel data.
        def initialize(panel:)
          @panel = panel
        end

        def view_template
          turbo_frame_tag "annotation_key_#{@panel.fetch(:id)}" do
            AnnotationPanel(panel: @panel)
          end
        end
      end
    end
  end
end
