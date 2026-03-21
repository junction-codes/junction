# frozen_string_literal: true

module Junction
  module Components
    # UI component to display the items for a pagination component.
    class PaginationContent < Base
      def view_template(&)
        ul(**attrs, &)
      end

      def ellipsis(*, **, &)
        PaginationEllipsis(*, **, &)
      end

      def first(*, **, &)
        PaginationFirst(*, **, &)
      end

      def item(*, **, &)
        PaginationItem(*, **, &)
      end

      def last(*, **, &)
        PaginationLast(*, **, &)
      end

      def next(*, **, &)
        PaginationNext(*, **, &)
      end

      def previous(*, **, &)
        PaginationPrevious(*, **, &)
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
