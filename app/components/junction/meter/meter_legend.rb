# frozen_string_literal: true

module Junction
  module Components
    module Meter
      # What each fill of a {Meter} stands for.
      #
      # Sits under the bar rather than inside it. A segment of a few percent has
      # no room to carry its own name.
      class MeterLegend < Base
        # Initializes the component.
        #
        # @param items [Array<Hash>] `{ label:, fill: }` per fill, in the same
        #   order as the meter's segments.
        # @param caption [String] An optional caption for the legend.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(items:, caption: nil, **user_attrs)
          @items = items
          @caption = caption

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            @items.each { |item| legend_item(item) }

            if @caption
              span(class: "ml-auto text-[12px] text-text-tertiary") { @caption }
            end
          end
        end

        private

        def default_attrs
          { class: "flex flex-wrap items-center gap-x-6 gap-y-1" }
        end

        # Renders a single item in the legend.
        #
        # @param item [Hash] Its label and the fill it names.
        def legend_item(item)
          span(class: "inline-flex items-center gap-2 text-[12px] text-text-body") do
            span(class: "w-2 h-2 rounded-full #{item[:fill] || Meter::FILL}",
                 aria_hidden: "true")
            plain item.fetch(:label)
          end
        end
      end
    end
  end
end
