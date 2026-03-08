# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a link in a breadcrumb trail.
    class BreadcrumbLink < Base
      def initialize(href: "#", **attrs)
        @href = href
        super(**attrs)
      end

      def view_template(&)
        a(href: @href, **attrs, &)
      end

      private

      def default_attrs
        {
          class: "transition-colors hover:text-foreground"
        }
      end
    end
  end
end
