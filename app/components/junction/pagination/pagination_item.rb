# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a single item in a pagination component.
    class PaginationItem < Base
      # Initializes a new component.
      #
      # @param href [String] The URL to link to.
      # @param active [Boolean] Whether the item is active.
      # @param turbo_action [String] Turbo action to use for pagination links.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(href: "#", active: false, turbo_action: "advance",
                     **user_attrs)
        @href = href
        @active = active
        @turbo_action = turbo_action

        super(**user_attrs)
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
          data: { turbo: { action: @turbo_action }.compact },
          href: @active ? "#" : @href,
          variant: @active ? :disabled : :ghost
        }
      end
    end
  end
end
