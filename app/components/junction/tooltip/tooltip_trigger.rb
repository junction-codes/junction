# frozen_string_literal: true

module Junction
  module Components
    module Tooltip
      # UI component to display a tooltip trigger.
      class TooltipTrigger < Base
        def view_template(&)
          div(**attrs, &)
        end

        private

        def default_attrs
          {
            data: { ruby_ui__tooltip_target: "trigger" },
            variant: :outline,
            class: "peer"
          }
        end
      end
    end
  end
end
