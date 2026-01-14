# frozen_string_literal: true

module Junction
  module Components
    class TableRow < Base
      def view_template(&)
        tr(**attrs, &)
      end

      def cell(*, **, &)
        render TableCell.new(*, **, &)
      end

      def head(*, **, &)
        render TableHead.new(*, **, &)
      end

      def sortable_head(*, **, &)
        render TableSortableHead.new(*, **, &)
      end

      private

      def default_attrs
        {
          class: "border-b transition-colors hover:bg-muted hover:bg-opacity-50 data-[state=selected]:bg-muted hover:bg-gray-50 dark:hover:bg-gray-700/50"
        }
      end
    end
  end
end
