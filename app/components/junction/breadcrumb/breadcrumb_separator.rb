# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a separator between breadcrumb items.
    class BreadcrumbSeparator < Base
      def view_template(&)
        li(**attrs) do
          block_given? ? yield : icon("chevron-right")
        end
      end

      private

      def default_attrs
        {
          aria: { hidden: true },
          class: "[&>svg]:w-3.5 [&>svg]:h-3.5",
          role: "presentation"
        }
      end
    end
  end
end
