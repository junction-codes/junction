# frozen_string_literal: true

module Junction
  module Components
    module Table
      class TableFooter < Base
        def view_template(&)
          tfoot(**attrs, &)
        end

        def row(...)
          render Row.new(...)
        end

        private

        def default_attrs
          {
            class: "border-t bg-muted bg-opacity-50 font-medium[& amp;>tr]:last:border-b-0"
          }
        end
      end
    end
  end
end
