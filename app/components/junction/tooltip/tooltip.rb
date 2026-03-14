# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a tooltip.
    class Tooltip < Base
      # Initializes a new component.
      #
      # @param placement [String] The placement of the tooltip in relation to
      #   the trigger.
      # @param user_attrs [Hash] Additional attributes to pass to the component.
      def initialize(placement: "top", **user_attrs)
        @placement = placement
        super(**user_attrs)
      end

      def view_template(&)
        div(**attrs, &)
      end

      def content(*, **, &)
        TooltipContent(*, **, &)
      end

      def trigger(*, **, &)
        TooltipTrigger(*, **, &)
      end

      private

      def default_attrs
        {
          data: {
            controller: "ruby-ui--tooltip",
            ruby_ui__tooltip_placement_value: @placement
          },
          class: "group"
        }
      end
    end
  end
end
