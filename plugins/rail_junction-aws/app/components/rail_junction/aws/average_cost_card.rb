# frozen_string_literal: true

module RailJunction
  module Aws
    module Components
      class AverageCostCard < CostCard
        def template
          render ::Components::StatCard.new(
            title: "Average Daily Costs",
            value:,
            icon: "dollar-sign"
          )
        end

        private

        def service
          @service ||= CostExplorerService.new(model: @object)
        end

        def value
          "$%.2f" % service.average_costs
        end
      end
    end
  end
end
