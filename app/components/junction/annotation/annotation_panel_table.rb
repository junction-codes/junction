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
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              t(".entity_types")
            end

            if panel.fetch(:entity_types).empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty") }
              return
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              Table do |table|
                table.header do |header|
                  header.row do |row|
                    row.head { t(".entity_type_tab") }
                    row.head { t(".known_for_type") }
                    row.head(class: "text-right") { t(".records") }
                    row.head { t(".top_value") }
                  end
                end

                table.body do |body|
                  panel.fetch(:entity_types).each do |row|
                    body.row do |table_row|
                      table_row.cell { entity_type_label(row.fetch(:type_id)) }
                      table_row.cell { row.fetch(:known_for_type) ? t(".known_badge") : t(".other_badge") }
                      table_row.cell(class: "text-right") { row.fetch(:count) }
                      table_row.cell(class: "font-mono text-xs") { row[:top_value].presence || "—" }
                    end
                  end
                end
              end
            end
          end
        end

        private

        def default_attrs
          {
            class: "space-y-3"
          }
        end

        # Human-readable label for an entity type.
        #
        # @param id [String] Machine-readable name of the entity type.
        # @return [String] Human-readable name of the entity type.
        def entity_type_label(id)
          Junction::Annotations::Overview.entity_types
            .find { |type| type.id == id }
            .model
            .model_name
            .human(count: 2)
        end
      end
    end
  end
end
