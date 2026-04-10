# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display the items for a pagination component.
      class PaginationContent < Base
        def view_template(&)
          ul(**attrs, &)
        end

        def ellipsis(...)
          render Ellipsis.new(...)
        end

        def first(...)
          render First.new(...)
        end

        def item(...)
          render PaginationItem.new(...)
        end

        def last(...)
          render Last.new(...)
        end

        def next(...)
          render Next.new(...)
        end

        def previous(...)
          render Previous.new(...)
        end

        private

        def default_attrs
          {
            class: "flex flex-row items-center gap-1"
          }
        end
      end
    end
  end
end
