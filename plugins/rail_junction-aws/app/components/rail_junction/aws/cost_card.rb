# frozen_string_literal: true

module RailJunction
  module Aws
    module Components
      # Base class for cost related stat cards.
      class CostCard < Base
        def render?
          !service.tags.empty?
        end

        private

        # Creates and memoizes a cost explorer service for this card's object.
        #
        # @return [CostExplorerService] The service instance.
        def service
          @service ||= CostExplorerService.new(model: @object)
        end
      end
    end
  end
end
