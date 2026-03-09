# frozen_string_literal: true

module Junction
  module Components
    # UI component to display the current page in a breadcrumb trail.
    class BreadcrumbPage < Base
      def view_template(&)
        span(**attrs, &)
      end

      private

      def default_attrs
        {
          aria: { current: "page" },
          class: "font-normal text-foreground"
        }
      end
    end
  end
end
