# frozen_string_literal: true

module Junction
  module Components
    module Meter
      # A share of a whole, drawn as a bar.
      #
      # @example How much of the field one value accounts for.
      #   Meter(value: 62, total: 118, size: :xs)
      #
      # @example How a total divides, with {MeterLegend} naming the parts.
      #   Meter(segments: [ { value: 272 }, { value: 37, fill: OTHER } ])
      class Meter < Base
        # Classes for each supported size.
        SIZES = {
          xs: "h-1.5 rounded-full",
          sm: "h-[18px] rounded",
          md: "h-5 rounded"
        }.freeze

        # Default fill color.
        FILL = "bg-accent-solid"

        # Initializes the component.
        #
        # @param value [Integer] The share, for a bar with one fill.
        # @param total [Integer] Total that the value is compared against,
        #   defaults to the sum of all segments.
        # @param segments [Array<Hash>] `{ value:, fill: }` per fill, for a bar
        #   divided into parts. Given with `value`, this wins.
        # @param size [Symbol] One of {SIZES}.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(value: nil, total: nil, segments: nil, size: :md,
                       **user_attrs)
          @segments = segments || [ { value: value.to_i } ]
          @total = total || @segments.sum { |segment| segment[:value].to_i }
          @size = size

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            @segments.each { |segment| fill(segment) }
          end
        end

        private

        def default_attrs
          {
            class: "flex w-full overflow-hidden bg-subtle #{SIZES.fetch(@size)}",
            aria_hidden: "true"
          }
        end

        # One fill.
        #
        # A share too small to see still gets a small sliver so that it gets
        # represented.
        #
        # @param segment [Hash] Its value and, optional fill color.
        def fill(segment)
          width = share(segment[:value].to_i)
          return if width.zero?

          div(class: "h-full #{segment[:fill] || FILL}",
              style: "width: #{width}%")
        end

        # Calculates the share of the track a segment takes.
        #
        # @param value [Integer] One segment's value.
        # @return [Numeric] How much of the track it takes.
        def share(value)
          return 0 if @total.zero? || value.zero?

          [ ((value.to_f / @total) * 100).round(1), 1 ].max
        end
      end
    end
  end
end
