# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Base for a field holding a repeating set of rows.
      #
      # Subclasses declare their columns and supply the rows to render. The
      # add and remove behavior comes from the `repeatable-rows` Stimulus
      # controller.
      #
      # @abstract
      class RowSet < FieldType
        # Grid classes for a row, by column count.
        #
        # Written out rather than interpolated. Tailwind scans this file for
        # literal class names, so a name built at runtime is never generated.
        GRID_COLUMNS = {
          2 => "grid-cols-1 md:grid-cols-2",
          3 => "grid-cols-1 md:grid-cols-3"
        }.freeze

        # Columns in each row, as attribute names.
        #
        # @return [Array<Symbol>] The columns.
        #
        # @raise [NotImplementedError] If not overridden.
        def self.columns
          raise NotImplementedError, "#{self} must define .columns"
        end

        def view_template
          div(id: section_id, data: { controller: "repeatable-rows" }) do
            render_label

            p(class: "mt-1 text-sm text-gray-500 dark:text-gray-400") { @help_text } if @help_text

            column_headings

            # Marks the section as submitted, so removing every row is saved
            # rather than read as "the form did not carry this field". The
            # blank row is discarded when the rows are normalized.
            blank_marker

            div(data: { repeatable_rows_target: "list" }, class: "mt-2 space-y-2") do
              rows.each { |row| render_row(row) }
            end

            template(data: { repeatable_rows_target: "rowTemplate" }) { render_row }

            add_button
          end
        end

        private

        # HTML id for the section so that it can be addressed unambiguously.
        #
        # @return [String] The id.
        def section_id
          "#{@method.to_s.dasherize}-field"
        end

        # Rows to render, ending with a blank one to type into.
        #
        # @return [Array<Hash>] The rows.
        #
        # @raise [NotImplementedError] If not overridden.
        def rows
          raise NotImplementedError, "#{self.class} must define #rows"
        end

        # HTML name for one column of a row.
        #
        # @param column [Symbol] The column.
        # @return [String] The name.
        def field_name(column)
          "#{entity_type}[#{@method}][][#{column}]"
        end

        def column_headings
          div(class: "mt-2 grid gap-2 #{grid_columns}") do
            self.class.columns.each do |column|
              span(class: "text-xs font-medium text-gray-500 dark:text-gray-400") do
                t(".#{column}")
              end
            end
          end
        end

        # A complete blank row, so it forms its own group when Rails parses the
        # repeated names. A marker carrying only the first column would merge
        # with the next row's remaining columns instead.
        def blank_marker
          self.class.columns.each do |column|
            input(type: "hidden", name: field_name(column), value: "")
          end
        end

        # Renders one row of inputs plus its remove button.
        #
        # @param row [Hash] The row's values, keyed by column.
        def render_row(row = {})
          values = row.to_h.symbolize_keys

          div(class: "flex items-start gap-2",
              data: { repeatable_rows_target: "row" }) do
            div(class: "grid flex-1 gap-2 #{grid_columns}") do
              self.class.columns.each do |column|
                input(
                  type: "text",
                  name: field_name(column),
                  value: values[column],
                  placeholder: t(".#{column}_placeholder", default: ""),
                  aria: { label: t(".#{column}") },
                  class: Field::Text::BASE_CLASSES
                )
              end
            end

            Button(type: "button", variant: :ghost, size: :sm, icon: true,
                   aria: { label: t(".remove_row") },
                   data: { action: "click->repeatable-rows#remove" }) do
              icon("trash", class: "w-4 h-4")
            end
          end
        end

        def add_button
          Button(type: "button", variant: :secondary, class: "mt-2",
                 data: { action: "click->repeatable-rows#add" }) do
            icon("plus", class: "w-4 h-4 mr-2")
            plain t(".add_row")
          end
        end

        def grid_columns
          GRID_COLUMNS.fetch(self.class.columns.size)
        end
      end
    end
  end
end
