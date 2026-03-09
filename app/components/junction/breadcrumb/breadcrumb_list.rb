# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a list of breadcrumb items.
    class BreadcrumbList < Base
      def view_template(&)
        ol(**attrs, &)
      end

      private

      def default_attrs
        {
          class: "flex flex-wrap items-center gap-1.5 break-words text-sm text-muted-foreground sm:gap-2.5"
        }
      end
    end
  end
end
