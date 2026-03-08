# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a breadcrumb trail.
    class Breadcrumb < Base
      def view_template(&)
        nav(**attrs, &)
      end

      private

      def default_attrs
        {
          aria: { label: "breadcrumb" }
        }
      end
    end
  end
end
