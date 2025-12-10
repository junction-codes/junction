# frozen_string_literal: true

module RailJunction
  module Aws
    module Components
      class MonthOverMonthChangeCard < CostCard
        def template
          render ::Components::StatCard.new(
            title: "Month-over-Month Cost Change",
            value: "%.2f%%" % value,
            icon:,
            status:
          )
        end

        private

        def icon
          value >= 0 ? "trending-up" : "trending-down"
        end

        def service
          @service ||= CostExplorerService.new(model: @object)
        end

        def status
          value >= 0 ? :healthy : :danger
        end

        def value
          @value ||= service.month_over_month_change
        end
      end
    end
  end
end
