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
            data: {
              ruby_ui__tooltip_target: "trigger",
              # focusin/focusout rather than focus/blur: this trigger is a
              # wrapper element and the focusable control sits inside it, so
              # the non-bubbling events would never reach us.
              action: [
                "mouseenter->ruby-ui--tooltip#show",
                "mouseleave->ruby-ui--tooltip#hide",
                "focusin->ruby-ui--tooltip#show",
                "focusout->ruby-ui--tooltip#hide"
              ]
            },
            variant: :outline
          }
        end
      end
    end
  end
end
