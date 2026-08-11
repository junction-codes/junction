# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # Renders the data table of an annotation panel.
      class AnnotationEntityTypePanelTable < Base
        attr_reader :panel

        def self.translation_path
          "junction.components.annotation_entity_type_panel_table"
        end

        # Initializes a new component.
        #
        # @param items [Array] Annotations items to display.
        # @param title [String] The title of the table.
        # @param empty_message [String] Message to display when there are no
        #   items.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(items:, title:, empty_message:, **user_attrs)
          @items = items
          @title = title
          @empty_message = empty_message

          super(**user_attrs)
        end

        def view_template
          section(**attrs) do
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              @title
            end

            if @items.empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { @empty_message }
              return
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              Table do |table|
                table.header do |header|
                  header.row do |row|
                    row.head { t(".key") }
                    row.head { t(".annotation_title") } if render_title?
                    row.head(class: "text-right") { t(".records") }
                    row.head { t(".top_value") }
                  end
                end

                table.body do |body|
                  @items.each do |row|
                    body.row do |table_row|
                      table_row.cell(class: "font-mono text-xs") { row.fetch(:key) }
                      table_row.cell { row.fetch(:title) } if render_title?
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

        # Determines whether the title column should be rendered.
        #
        # @return [Boolean] Whether the title should be rendered.
        def render_title?
          return @render_title if defined?(@render_title)

          @render_title ||= @items.any? { |item| item[:title].present? }
        end
      end
    end
  end
end
