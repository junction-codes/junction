# frozen_string_literal: true

module Junction
  module Components
    module Table
      class TableHeader < Base
        def view_template(&)
          thead(**attrs, &)
        end

        def row(...)
          render Row.new(...)
        end

        private

        def default_attrs
          {
            class: "bg-gray-50 dark:bg-gray-700 [&_tr]:border-b"
          }
        end
      end
    end
  end
end
