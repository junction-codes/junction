# frozen_string_literal: true

module Components
  class TableFooter < Base
    def view_template(&)
      tfoot(**attrs, &)
    end

    def row(*, **, &)
      render TableRow.new(*, **, &)
    end

    private

    def default_attrs
      {
        class: "border-t bg-muted bg-opacity-50 font-medium[& amp;>tr]:last:border-b-0"
      }
    end
  end
end
