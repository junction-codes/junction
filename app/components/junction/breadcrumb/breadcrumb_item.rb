# frozen_string_literal: true

module Junction
  module Components
    # UI component to display an item in a breadcrumb trail.
    class BreadcrumbItem < Base
      def view_template(&)
        li(**attrs, &)
      end

      private

      def default_attrs
        {
          class: "inline-flex items-center gap-1.5"
        }
      end
    end
  end
end
