# frozen_string_literal: true

module Junction
  module Components
    module Tooltip
      # UI component to display a tooltip.
      class Tooltip < Base
        # Initializes a new component.
        #
        # @param placement [String] The placement of the tooltip in relation to
        #   the trigger.
        # @param offset [Integer] Optional gap from the trigger, in pixels.
        # @param user_attrs [Hash] Additional attributes to pass to the
        #   component.
        def initialize(placement: "top", offset: nil, **user_attrs)
          @placement = placement
          @offset = offset
          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs, &)
        end

        def content(...)
          render TooltipContent.new(...)
        end

        def trigger(...)
          render TooltipTrigger.new(...)
        end

        private

        def default_attrs
          data = {
            controller: "ruby-ui--tooltip",
            ruby_ui__tooltip_placement_value: @placement
          }
          data[:ruby_ui__tooltip_offset_value] = @offset if @offset

          { data:, class: "group" }
        end
      end
    end
  end
end
