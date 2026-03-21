# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a pagination navigation control.
    class Pagination < Base
      def view_template(&)
        nav(**attrs, &)
      end

      def content(*, **, &)
        PaginationContent(*, **, &)
      end

      private

      def default_attrs
        {
          aria: { label: "pagination" },
          class: "mx-auto flex w-full justify-center",
          role: "navigation"
        }
      end
    end
  end
end
