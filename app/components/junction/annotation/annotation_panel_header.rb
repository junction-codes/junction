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
            SettingsDetailHeader(title: panel.fetch(:label),
                                 subtitle: panel[:title].presence,
                                 badge: state_badge)

            meta_row
          end
        end

        private

        def default_attrs
          { class: "space-y-3" }
        end

        # Renders either the "known" or "other" badge for an annotation.
        #
        # @return [Hash] The badge's label and variant.
        def state_badge
          known = panel.fetch(:known)

          {
            label: known ? t(".known_badge") : t(".other_badge"),
            variant: known ? :success : :outline
          }
        end

        # Metadata about the annotation.
        def meta_row
          div(class: "flex flex-wrap items-center gap-2") do
            meta_chip(t(".declared_by", plugin: panel[:declared_by])) if panel[:declared_by]
            meta_chip(t(".placeholder", value: panel[:placeholder])) if panel[:placeholder]
            meta_chip(t(".records_total", count: panel.fetch(:total_count)))
          end
        end

        # Renders a chip for a piece of metadata.
        #
        # @param text [String] What the chip says.
        def meta_chip(text)
          span(class: "inline-flex items-center rounded-md border border-border " \
                      "bg-background px-2 py-1 text-[11.5px] text-text-tertiary") do
            text
          end
        end
      end
    end
  end
end
