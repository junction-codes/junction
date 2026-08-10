# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders the header of an annotation panel.
      class AnnotationPanelHeader < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_panel_header"
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
            div(class: "flex flex-wrap items-center gap-2") do
              h3(class: "text-lg font-semibold text-gray-900 dark:text-gray-100") do
                panel.fetch(:label)
              end
              render_known_other_badge(panel.fetch(:known))
            end

            if panel[:title].present?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { panel.fetch(:title) }
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

        # Renders either the "known" or "other" badge for the annotations.
        #
        # @param known [Boolean] Whether the annotation is known.
        def render_known_other_badge(known)
          Badge(variant: known ? :default : :secondary) do
            known ? t(".known_badge") : t(".other_badge")
          end
        end
      end
    end
  end
end
