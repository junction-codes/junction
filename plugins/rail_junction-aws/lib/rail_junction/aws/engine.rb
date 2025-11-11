# frozen_string_literal: true

module RailJunction
  module Aws
    class Engine < ::Rails::Engine
      ANNOTATION_COST_INSIGHTS_TAGS = "aws.amazon.com/cost-insights-tags"

      isolate_namespace RailJunction::Aws

      config.after_initialize do
        ::PluginRegistry.register_annotation(
          context: ::Component,
          key: ANNOTATION_COST_INSIGHTS_TAGS,
          title: "AWS Cost Insights Tags",
          placeholder: "project=my-project mytag=value"
        )

        ::PluginRegistry.register_annotation(
          context: ::Resource,
          key: ANNOTATION_COST_INSIGHTS_TAGS,
          title: "AWS Cost Insights Tags",
          placeholder: "project=my-project mytag=value"
        )

        ::PluginRegistry.register_action(
          context: ::Component,
          path: 'aws/costs',
          method: :component_aws_costs_path,
          controller: 'rail_junction/aws/costs'
        )

        ::PluginRegistry.register_tab(
          context: ::Component,
          title: "Costs",
          icon: "dollar-sign",
          action: :component_aws_costs_path,
          if: ->(context:) { context.annotations[ANNOTATION_COST_INSIGHTS_TAGS].present? }
        )

        ::PluginRegistry.register_ui_component(
          context_class: ::Component,
          slot: :overview_cards,
          component: Components::AverageCostCard
        )

        ::PluginRegistry.register_ui_component(
          context_class: ::Component,
          slot: :overview_cards,
          component: Components::TotalCostCard
        )

        ::PluginRegistry.register_ui_component(
          context_class: ::Component,
          slot: :overview_cards,
          component: Components::MonthOverMonthChangeCard
        )
      end
    end
  end
end
