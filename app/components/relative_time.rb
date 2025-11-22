# frozen_string_literal: true

module Components
  # Display a timestamp as a relative time (e.g., "5 minutes ago").
  class RelativeTime < Base
    include Phlex::Rails::Helpers::TimeAgoInWords

    # Initialize a new component.
    #
    # @param time [Time, DateTime] The timestamp to display.
    # @param format [Symbol] The format to use for the tooltip.
    # @param user_attrs [Hash] Additional HTML attributes for the component.
    def initialize(time:, format: :datetime, **user_attrs)
      @time = time
      @format = format
      super(**user_attrs)
    end

    def view_template
      time(**attrs) do
        "#{time_ago_in_words(@time)} ago"
      end
    end

    private

    def default_attrs
      {
        datetime: @time.to_formatted_s(@format),
        title: @time.to_formatted_s(@format)
      }
    end
  end
end
