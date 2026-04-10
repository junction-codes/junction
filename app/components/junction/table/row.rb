# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Row < Base
        def view_template(&)
          tr(**attrs, &)
        end

        def cell(...)
          render Cell.new(...)
        end

        def head(...)
          render Head.new(...)
        end

        def sortable_head(...)
          render SortableHead.new(...)
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
end
