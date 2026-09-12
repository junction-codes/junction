# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Head < Base
        def view_template(&)
          th(**attrs, &)
        end

        private

        def default_attrs
          {
            scope: "col",
            class: "h-11 px-4 text-left align-middle text-[10.5px] font-semibold " \
                   "uppercase tracking-[0.06em] text-muted-foreground " \
                   "[&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]"
          }
        end
      end
    end
  end
end
