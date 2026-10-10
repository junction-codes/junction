# frozen_string_literal: true

module Junction
  module Components
    module Annotation
      # The annotation keys one kind of entity carries.
      #
      # Both halves of {AnnotationEntityTypePanel} are the same table. A
      # declared key has a title a plugin gave it; an undeclared one has a dot
      # and a sentence saying nobody claims it, in the same column, so the two
      # lists line up and can be compared down the page.
      class AnnotationEntityTypePanelTable < Base
        attr_reader :items

        def self.translation_path
          "junction.components.annotation_entity_type_panel_table"
        end

        # Initializes a new component.
        #
        # @param items [Array<Hash>] The keys, with their counts and most used
        #   value.
        # @param highest [Integer] The most used key's count.
        # @param declared [Boolean] Whether the annotations are declared by a
        #   plugin.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(items:, highest: 0, declared: true, **user_attrs)
          @items = items
          @highest = highest
          @declared = declared

          super(**user_attrs)
        end

        def view_template
          Table(**attrs) do |table|
            table.header { |header| header.row { |row| heads(row) } }
            table.body { |body| items.each { |item| key_row(body, item) } }
          end
        end

        private

        # Renders the Header row for the table.
        #
        # @param row [Table::TableRow] The header row.
        def heads(row)
          row.head(class: "w-6") { span(class: "sr-only") { t(".marker") } } unless @declared
          row.head { t(".key") }
          row.head { @declared ? t(".title") : t(".claim") }
          row.head(class: "w-[140px]") { span(class: "sr-only") { t(".share") } }
          row.head(class: "text-right") { t(".uses") }
          row.head { t(".top_value") }
        end

        # Renders a row for a single annotation key.
        #
        # @param body [Table::TableBody] The table's body.
        # @param item [Hash] One key.
        def key_row(body, item)
          body.row do |row|
            row.cell(class: "pr-0") { unclaimed_dot } unless @declared

            row.cell(class: "font-mono text-xs") { item.fetch(:key) }
            row.cell(class: "text-[12px] text-text-tertiary") { claim(item) }
            row.cell { Meter(value: item.fetch(:count), total: @highest, size: :xs) }
            row.cell(class: "text-right tabular-nums") { item.fetch(:count) }
            row.cell(class: "font-mono text-xs") do
              item[:top_value].presence || "—"
            end
          end
        end

        # The title of the annotation key, if defined.
        #
        # @param item [Hash] One key.
        # @return [String] The claim.
        def claim(item)
          return t(".unclaimed") unless @declared

          item[:title].presence || t(".untitled")
        end

        # Marks a key nothing claims, as the index pane marks them.
        def unclaimed_dot
          span(class: "inline-block w-[5px] h-[5px] rounded-full bg-warning",
               aria_hidden: "true")
        end
      end
    end
  end
end
