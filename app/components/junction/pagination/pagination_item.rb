# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a single item in a pagination component.
    class PaginationItem < Base
      def initialize(href: "#", active: false, **attrs)
        @href = href
        @active = active

        super(**attrs)
      end

      def view_template(&block)
        li { Link(**attrs, &block) }
      end

      private

      def default_attrs
        {
          aria: {
            current: @active ? "page" : nil,
            disabled: @active ? "true" : nil
          },
          class: [],
          data: { turbo_action: "advance" },
          href: @active ? "#" : @href,
          variant: @active ? :disabled : :ghost
        }
      end
    end
  end
end
