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
            class: "border-b border-subtle transition-colors last:border-0 " \
                   "hover:bg-subtle/60 data-[state=selected]:bg-muted"
          }
        end
      end
    end
  end
end
