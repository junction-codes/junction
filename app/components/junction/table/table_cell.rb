# frozen_string_literal: true

module Junction
  module Components
    class TableCell < Base
      def view_template(&)
        td(**attrs, &)
      end

      private

      def default_attrs
        {
          class: "px-6 py-4 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]"
        }
      end
    end
  end
end
