# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # One kind of entity, and the annotation keys it carries.
      class AnnotationEntityTypePanel < Base
        attr_reader :panel

        # Fill color for keys not defined by a plugin.
        OTHER_FILL = "bg-line-strong"

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
            header
            annotated? ? declared_split : nothing_annotated
            declared_keys
            undeclared_keys
          end
        end

        private

        def default_attrs
          { class: "space-y-6" }
        end

        # Header for the entity type.
        def header
          SettingsDetailHeader(title: panel.fetch(:label), mono: false,
                               chip: panel.fetch(:id),
                               description: summary)
        end

        # Summary of the entity type's annotation statistics.
        #
        # @return [String] The kind's totals, as a sentence.
        def summary
          [
            t(".records", count: panel.fetch(:record_count)),
            t(".annotated", count: panel.fetch(:total_count)),
            t(".keys_in_use", count: panel.fetch(:keys_in_use))
          ].join("  ·  ")
        end

        # Whether or not anything of this kind carries an annotation.
        #
        # @return [Boolean] Whether anything of this kind carries an annotation.
        def annotated?
          (panel.fetch(:known_total) + panel.fetch(:other_total)).positive?
        end

        # Renders a note to the user when no annotations have been set for this
        # kind.
        #
        # This is displayed in place of the known vs other meter when no
        # entities of the current kind carry any annotations.
        def nothing_annotated
          div(class: "rounded-lg border border-border bg-background " \
                     "px-6 py-8 text-center space-y-2") do
            icon("tags", class: "mx-auto w-6 h-6 text-text-tertiary")

            p(class: "text-[15px] font-semibold text-foreground") do
              t(".nothing_title", kind: kind_name)
            end

            p(class: "mx-auto max-w-md text-[13px] leading-5 text-text-tertiary") do
              t(panel.fetch(:known).any? ? ".nothing_declared" : ".nothing_undeclared")
            end
          end
        end

        # The name of the entity type, formatted for use in prose.
        #
        # @return [String] The kind, as the sentence needs it.
        def kind_name
          panel.fetch(:label).downcase
        end

        # Renders a meter to show the split between defined and undefined
        # annotations.
        #
        # Defined (or known) annotations are those that have been explicitly
        # declared by a plugin.
        def declared_split
          declared = panel.fetch(:known_total)
          other = panel.fetch(:other_total)

          div(class: "space-y-2.5") do
            Meter(segments: [ { value: declared },
                              { value: other, fill: OTHER_FILL } ])

            MeterLegend(
              items: [ { label: t(".declared_segment", count: declared) },
                       { label: t(".other_segment", count: other),
                         fill: OTHER_FILL } ],
              caption: t(".coverage", percent: Junction::Percentage.of(declared, declared + other))
            )
          end
        end

        # Annotations keys declared by a plugin.
        def declared_keys
          return if panel.fetch(:known).empty? && !annotated?

          section(class: "space-y-3") do
            section_heading(t(".declared"), t(".registration_order"))

            if panel.fetch(:known).empty?
              p(class: "text-sm text-text-tertiary") { t(".empty_known") }
              next
            end

            AnnotationEntityTypePanelTable(items: panel.fetch(:known),
                                           highest: highest_count, declared: true)
          end
        end

        # Annotations keys in the catalog that aren't declared by a plugin.
        def undeclared_keys
          other = panel.fetch(:other)
          return if other.empty?

          section(class: "space-y-3") do
            section_heading(
              t(".other"),
              [ t(".other_keys", count: other.size),
                t(".other_uses", count: panel.fetch(:other_total)) ].join("  ·  ")
            )

            AnnotationEntityTypePanelTable(items: other, highest: highest_count,
                                           declared: false)

            p(class: "text-[11.5px] leading-5 text-text-tertiary") do
              t(".undeclared_note")
            end
          end
        end

        # Renders the heading for a single section.
        #
        # @param title [String] Title of the section.
        # @param hint [String] Additional information or context for the
        #   section.
        def section_heading(title, hint)
          div(class: "flex items-baseline justify-between gap-4") do
            h3(class: "text-[14px] font-semibold text-foreground") { title }
            span(class: "text-[11.5px] text-text-tertiary") { hint }
          end
        end

        # Annotation key that appears the most frequently within the catalog.
        #
        # Calculated from both declared and undeclared annotation keys.
        #
        # @return [Integer] The highest count.
        def highest_count
          @highest_count ||=
            (panel.fetch(:known) + panel.fetch(:other))
            .filter_map { |row| row[:count] }.max.to_i
        end

        # Calculates the percentage of a part relative to the whole.
        #
      end
    end
  end
end
