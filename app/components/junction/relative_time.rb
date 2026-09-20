# frozen_string_literal: true

module Junction
  module Components
    # Display a timestamp as a relative time (e.g., "5 minutes ago").
    class RelativeTime < Base
      include Phlex::Rails::Helpers::TimeAgoInWords

      # Initialize a new component.
      #
      # @param time       [Time, DateTime] The timestamp to display.
      # @param format     [Symbol]         The format to use for the tooltip.
      # @param user_attrs [Hash]           Additional HTML attributes for the component.
      def initialize(time:, format: :datetime, **user_attrs)
        @time = time
        @format = format
        super(**user_attrs)
      end

      def view_template
        # The tooltip's wrapper is a block, so in a flex row it collapses and
        # the time overflows whatever sits beside it.
        Tooltip(class: "w-fit shrink-0") do |tooltip|
          tooltip.trigger do
            time(**attrs) { t(".ago", time: time_ago_in_words(@time)) }
          end

          tooltip.content { plain @time.to_formatted_s(@format) }
        end
      end

      private

      def default_attrs
        {
          datetime: @time.iso8601
        }
      end
    end
  end
end
