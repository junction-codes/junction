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
            class: "[&_tr]:border-b [&_tr]:border-border"
          }
        end
      end
    end
  end
end
