# frozen_string_literal: true

module Components
  class TableHead < Base
    def view_template(&)
      th(**attrs, &)
    end

    private

    def default_attrs
      {
        scope: "col",
        class: "h-10 px-6 py-3 text-left text-xs align-middle font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]"
      }
    end
  end
end
