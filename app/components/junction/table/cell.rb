# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Cell < Base
        def view_template(&)
          td(**attrs, &)
        end

        private

        def default_attrs
          {
            # No `whitespace-nowrap` here: it makes the auto table layout size
            # every column to its longest unbroken line, so a long description
            # pushes the later columns off and no amount of `max-width` on the
            # content can pull them back.
            class: "px-4 py-3 align-middle " \
                   "[&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]"
          }
        end
      end
    end
  end
end
