# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders the charts of an annotation panel.
      class AnnotationPanelCharts < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_panel_charts"
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
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-3") do
              h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
                t(".value_breakdown")
              end

              bar_chart panel.dig(:charts, :value_breakdown),
                        id: annotation_chart_id(panel, "value-breakdown"),
                        height: "280px",
                        library: { indexAxis: "y" }
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-3") do
              h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
                t(".by_entity_type")
              end

              bar_chart panel.dig(:charts, :by_entity_type),
                        id: annotation_chart_id(panel, "by-entity-type"),
                        height: "280px"
            end
          end
        end

        private

        def default_attrs
          {
            class: "grid grid-cols-1 xl:grid-cols-2 gap-4"
          }
        end

        def annotation_chart_id(panel, name)
          "annotations-#{panel.fetch(:id)}-#{name}"
        end
      end
    end
  end
end
