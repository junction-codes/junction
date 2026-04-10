# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Body < Base
        def view_template(&)
          tbody(**attrs, &)
        end

        def row(...)
          render Row.new(...)
        end

        private

        def default_attrs
          {
            class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700 [&_tr:last-child]:border-0"
          }
        end
      end
    end
  end
end
