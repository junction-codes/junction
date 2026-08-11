# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders a panel for a single annotation key.
      class AnnotationPanel < Base
        attr_reader :panel

        # Initializes a new component.
        #
        # @param panel [Hash] The annotation key panel data.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(panel:, **user_attrs)
          @panel = panel

          super(**user_attrs)
        end

        def view_template
          section(**attrs) do
            AnnotationPanelHeader(panel:)
            AnnotationPanelCharts(panel:)
            AnnotationPanelTable(panel:)
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
