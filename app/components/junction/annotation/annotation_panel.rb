# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders a panel for a single annotation key.
      class AnnotationPanel < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_panel"
        end

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
            values_in_use
            AnnotationPanelTable(panel:)
          end
        end

        private

        def default_attrs
          { class: "space-y-6" }
        end

        # Every value the key carries, sorted most used to least.
        def values_in_use
          values = panel.fetch(:values, [])
          return if values.empty?

          section(class: "space-y-3") do
            div do
              h3(class: "text-[14px] font-semibold text-foreground") do
                t(".values_in_use")
              end
              p(class: "text-[12.5px] text-text-tertiary") do
                t(".values_summary", values: panel.fetch(:values_total, values.size),
                                     count: panel.fetch(:total_count))
              end
            end

            div(class: "space-y-1.5") do
              highest = values.first.fetch(:count)
              values.each { |row| value_row(row, highest) }
            end

            remainder
          end
        end

        # Display the count of additional values not shown in the panel, if any.
        def remainder
          hidden = panel.fetch(:values_total, 0) - panel.fetch(:values, []).size
          return if hidden < 1

          p(class: "text-[12px] text-text-tertiary") do
            t(".more_values", count: hidden)
          end
        end

        # Row for a single annotation value.
        #
        # @param row [Hash] The value and how often it's used.
        # @param highest [Integer] The most-used value's count
        def value_row(row, highest)
          div(class: "flex items-center gap-4") do
            span(class: "w-40 shrink-0 truncate font-mono text-[12.5px] " \
                        "text-text-body") { row.fetch(:value) }

            div(class: "flex-1") do
              Meter(value: row.fetch(:count), total: highest, size: :sm)
            end

            span(class: "w-12 shrink-0 text-right tabular-nums text-[12.5px] " \
                        "text-text-tertiary") { row.fetch(:count).to_s }
          end
        end
      end
    end
  end
end
