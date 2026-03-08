# frozen_string_literal: true

module Junction
  module Components
    # UI component to display an ellipsis in a breadcrumb.
    #
    # @todo Should we just use an actual ellipsis character?
    class BreadcrumbEllipsis < Base
      def view_template(&)
        span(**attrs) do
          icon
          span(class: "sr-only") { "More" }
        end
      end

      private

      def icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-4 h-4",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round"
        ) do |s|
          s.circle(cx: "12", cy: "12", r: "1")
          s.circle(cx: "19", cy: "12", r: "1")
          s.circle(cx: "5", cy: "12", r: "1")
        end
      end

      def default_attrs
        {
          aria: { hidden: true },
          class: "flex h-9 w-9 items-center justify-center",
          role: "presentation"
        }
      end
    end
  end
end
