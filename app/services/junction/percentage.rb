# frozen_string_literal: true

module Junction
  # A share of a whole, as a whole number.
  #
  # Ensures consistent rounding of percentages.
  module Percentage
    # @param count [Integer] The part.
    # @param total [Integer] The whole.
    # @return [Integer] The share, rounded, or zero when there is no whole.
    def self.of(count, total)
      return 0 if total.to_i.zero?

      ((count.to_f / total) * 100).round
    end
  end
end
