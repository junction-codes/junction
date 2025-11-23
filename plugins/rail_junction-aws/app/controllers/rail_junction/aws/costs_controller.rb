# frozen_string_literal: true

module RailJunction
  module Aws
    class CostsController < ::ApplicationController
      before_action :set_component

      def index
        render RailJunction::Aws::Views::Costs::Index.new(
          object: @component,
          frame_id: "component-aws-costs",
          historical_costs: CostExplorerService.new(model: @component).historical_costs,
          service_costs: CostExplorerService.new(model: @component).costs_by_service
        )
      end

      private

      def set_component
        @component = ::Component.find(params[:component_id])
      end
    end
  end
end
