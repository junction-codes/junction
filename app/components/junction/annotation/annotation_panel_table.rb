# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders the data table of an annotation panel.
      class AnnotationPanelTable < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_panel_table"
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
          section(**attrs) do
            h3(class: "text-[14px] font-semibold text-foreground") do
              t(".entity_types")
            end

            if panel.fetch(:entity_types).empty?
              p(class: "text-sm text-text-tertiary") { t(".empty") }
              next
            end

            usage_table
          end
        end

        private

        def default_attrs
          { class: "space-y-3" }
        end

        def usage_table
          Table do |table|
            table.header do |header|
              header.row do |row|
                row.head { t(".entity_type_tab") }
                row.head(class: "text-right") { t(".records") }
                row.head { t(".coverage") }
                row.head { t(".top_value") }
              end
            end

            table.body do |body|
              panel.fetch(:entity_types).each { |row| usage_row(body, row) }
            end
          end
        end

        # @param body [Table::TableBody] The table's body.
        # @param row [Hash] One kind's usage.
        def usage_row(body, row)
          body.row do |table_row|
            table_row.cell { row.fetch(:label) }
            table_row.cell(class: "text-right tabular-nums") { row.fetch(:count) }
            table_row.cell { coverage_cell(row[:coverage].to_i) }
            table_row.cell(class: "font-mono text-xs") do
              row[:top_value].presence || "—"
            end
          end
        end

        # Bar representing the percentage of entities carrying an annotation
        # key.
        #
        # @param percent [Integer] The share of that kind carrying the key.
        def coverage_cell(percent)
          div(class: "flex items-center gap-2") do
            div(class: "w-[120px]") do
              Meter(value: percent, total: 100, size: :xs)
            end

            span(class: "tabular-nums text-[12px] text-text-tertiary") do
              "#{percent}%"
            end
          end
        end
      end
    end
  end
end
