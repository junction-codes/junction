# frozen_string_literal: true

module RailJunction
  module Aws
    module Components
      class TotalCostCard < CostCard
        def template
          render ::Components::StatCard.new(
            title: "Total Cost (Last 30d)",
            value:,
            icon: "dollar-sign"
          )
        end

        private

        def service
          @service ||= CostExplorerService.new(model: @object)
        end

        def value
          "$%.2f" % service.total_costs
        end
      end
    end
  end
end
