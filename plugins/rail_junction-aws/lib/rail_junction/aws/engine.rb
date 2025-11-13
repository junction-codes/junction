# frozen_string_literal: true

module RailJunction
  module Aws
    class Engine < ::Rails::Engine
      ANNOTATION_COST_INSIGHTS_TAGS = "aws.amazon.com/cost-insights-tags"

      isolate_namespace RailJunction::Aws

      config.after_initialize do
        Plugin.register "aws" do |plugin|
          plugin.for_entity ::Component do |entity|
            entity.annotation key: ANNOTATION_COST_INSIGHTS_TAGS,
                              title: "AWS Cost Insights Tags",
                              placeholder: "project=my-project mytag=value"

            entity.action path: 'aws/costs',  method: :component_aws_costs_path,
                          controller: 'rail_junction/aws/costs'
            entity.tab title: "Costs", icon: "dollar-sign",
                       action: :component_aws_costs_path,
                       if: ->(context:) { context.annotations[ANNOTATION_COST_INSIGHTS_TAGS].present? }

            entity.component slot: :overview_cards, component: Components::AverageCostCard
            entity.component slot: :overview_cards, component: Components::TotalCostCard
            entity.component slot: :overview_cards, component: Components::MonthOverMonthChangeCard
          end

          plugin.for_entity ::Resource do |entity|
            entity.annotation key: ANNOTATION_COST_INSIGHTS_TAGS,
                                       title: "AWS Cost Insights Tags",
                                       placeholder: "project=my-project mytag=value"
          end
        end
      end
    end
  end
end
