# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Table < Base
        def view_template(&)
          div(class: "relative w-full overflow-auto") do
            table(**attrs, &)
          end
        end

        def body(...)
          render Body.new(...)
        end

        def caption(...)
          render Caption.new(...)
        end

        def footer(...)
          render TableFooter.new(...)
        end

        def header(...)
          render TableHeader.new(...)
        end

        private

        def default_attrs
          {
            class: "w-full caption-bottom text-sm"
          }
        end
      end
    end
  end
end
