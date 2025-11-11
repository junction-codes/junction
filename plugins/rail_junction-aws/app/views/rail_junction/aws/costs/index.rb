# frozen_string_literal: true

module RailJunction
  module Aws
    class Views::Costs::Index < ::Components::Base
      def initialize(object:, frame_id:, historical_costs:, service_costs:)
        @object = object
        @frame_id = frame_id
        @historical_costs = historical_costs
        @service_costs = service_costs
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          div do
            Tabs(default_value: "account") do
              TabsList do
                TabsTrigger(value: "historical") { "Historical" }
                TabsTrigger(value: "services") { "By Service" }
              end

              TabsContent(value: "historical") do
                h4(class: "font-bold text-center text-lg") { "Historical costs" }
                line_chart @historical_costs, round: 2, zeros: true, prefix: "$"
              end

              TabsContent(value: "services") do
                h4(class: "font-bold text-center text-lg") { "Costs by service" }
                pie_chart @service_costs, round: 2, zeros: true, prefix: "$"
              end
            end
          end
        end
      end
    end
  end
end
