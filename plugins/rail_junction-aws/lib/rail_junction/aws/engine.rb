# frozen_string_literal: true

module RailJunction
  module Aws
    class Engine < ::Rails::Engine
      ANNOTATION_COST_INSIGHTS_TAGS = "aws.amazon.com/cost-insights-tags"

      HAS_COST_INSIGHTS = ->(context:) { context.annotations[ANNOTATION_COST_INSIGHTS_TAGS].present? }.freeze

      isolate_namespace RailJunction::Aws

      ActiveSupport.on_load(:junction_plugins) do
        plugin = Plugin.new("aws", RailJunction::Aws, icon: "amazon", title: "Amazon Web Services")
        plugin.for_entity "Component", HAS_COST_INSIGHTS do |entity|
          entity.annotation key: ANNOTATION_COST_INSIGHTS_TAGS,
                            title: "AWS Cost Insights Tags",
                            placeholder: "project=my-project mytag=value"

          entity.action path: "aws/costs",  method: :component_aws_costs_path,
                        controller: "rail_junction/aws/costs"
          entity.tab title: "Costs", icon: "dollar-sign",
                      action: :component_aws_costs_path

          entity.component slot: :overview_cards, component: "Components::AverageCostCard"
          entity.component slot: :overview_cards, component: "Components::TotalCostCard"
          entity.component slot: :overview_cards, component: "Components::MonthOverMonthChangeCard"
        end

        plugin.for_entity "Resource", HAS_COST_INSIGHTS do |entity|
          entity.annotation key: ANNOTATION_COST_INSIGHTS_TAGS,
                                      title: "AWS Cost Insights Tags",
                                      placeholder: "project=my-project mytag=value"
        end

        plugin.register
      end
    end
  end
end
