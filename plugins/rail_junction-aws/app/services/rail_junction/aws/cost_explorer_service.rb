# frozen_string_literal: true

require "aws-sdk-costexplorer"

module RailJunction
  module Aws
    # Service to fetch cost data from AWS Cost Explorer API
    class CostExplorerService
      # Cache for API calls.
      CACHE_EXPIRES_IN = 24.hours

      def initialize(model:)
        @model = model
      end

      # Calculate total costs by AWS service over the specified period.
      #
      # @param period [ActiveSupport::Duration] The time period to retrieve
      #   costs for.
      # @return [Hash{String => Float}] A hash mapping service names to their
      #   total costs.
      def costs_by_service(period: 30.days)
        with_cache(period) do
          costs = Hash.new(0.0)
          cost_and_usage(period: period, granularity: "MONTHLY", group_by: [ { type: "DIMENSION", key: "SERVICE" } ]).each do |result|
            result.groups.each do |group|
              costs[group.keys.first] += group.metrics["UnblendedCost"].amount.to_f
            end
          end

          costs
        end
      end

      # Retrieve historical daily costs over the specified period.
      #
      # @param period [ActiveSupport::Duration] The time period to retrieve
      #   costs for (default: 30 days).
      # @return [Array<Array>] An array of arrays containing date and cost
      #   amount.
      def historical_costs(period: 30.days)
        with_cache(period) do
          cost_and_usage(period: period).map do |result|
            [ result.time_period.start, result.total["UnblendedCost"].amount.to_f ]
          end
        end
      end

      # Calculate average costs over the specified period.
      #
      # @param period [ActiveSupport::Duration] The time period to retrieve
      #   costs for.
      # @param granularity [String] The granularity of the data returned.
      # @return [Float] The average cost amount.
      def average_costs(period: 30.days, granularity: "DAILY")
        with_cache(period, granularity) do
          total = 0.0
          results = cost_and_usage(period: period, granularity:)
          results.each do |result|
            total += result.total["UnblendedCost"].amount.to_f
          end

          total / results.size
        end
      end

      # Calculate month-over-month cost change percentage.
      #
      # @return [Float] The month-over-month cost change percentage.
      def month_over_month_change
        with_cache do
          current_month_cost = total_costs(period: 30.days)
          previous_month_cost = total_costs(period: 60.days) - current_month_cost

          return 0.0 if previous_month_cost.zero?

          ((current_month_cost - previous_month_cost) / previous_month_cost) * 100.0
        end
      end

      # Calculate total costs over the specified period.
      #
      # @param period [ActiveSupport::Duration] The time period to retrieve
      #  costs for.
      # @return [Float] The total cost amount.
      def total_costs(period: 30.days)
        with_cache(period) do
          total = 0.0
          cost_and_usage(period: period, granularity: "MONTHLY").each do |result|
            total += result.total["UnblendedCost"].amount.to_f
          end

          total
        end
      end

      # Cost insights tags associated with the model.
      #
      # @return [Hash{String => String}] A hash mapping tag keys to their
      #   values.
      def tags
        return @tags if @tags

        annotation = @model.annotations[Engine::ANNOTATION_COST_INSIGHTS_TAGS] || ""
        @tags = annotation.split(",").to_h do |tag_pair|
          key, value = tag_pair.split("=").map(&:strip)
          [ key, value ]
        end
      end

      private

      def client
        @client = ::Aws::CostExplorer::Client.new
      end

      def with_cache(*facets, &)
        key = cache_key_for([ caller_locations(1, 1)[0].base_label ] + facets)
        Rails.cache.fetch(key, expires_in: CACHE_EXPIRES_IN) { yield }
      end

      def cache_key_for(facets)
        [
          "aws",
          facets,
          @model.class.model_name.singular,
          @model.id
        ].flatten.join("/")
      end

      # Retrieve cost and usage data from AWS Cost Explorer.
      #
      # @param period [ActiveSupport::Duration] The time period to retrieve data
      #   for.
      # @param granularity [String] The granularity of the data returned.
      # @param metrics [Array<String>] The metrics to retrieve.
      # @param group_by [Array<Hash>] Dimensions to group the data by.
      # @return [Array<Aws::CostExplorer::Types::ResultByTime>] The cost and
      #   usage data.
      def cost_and_usage(period: 30.days, granularity: "DAILY", metrics: [ "UnblendedCost" ], group_by: [])
        client.get_cost_and_usage({
          filter:,
          granularity:,
          metrics:,
          group_by:,
          time_period: {
            start: (Time.now - period).strftime("%Y-%m-%d"),
            end: Time.now.utc.strftime("%Y-%m-%d")
          }
        }).results_by_time
      end

      def dimension_values(period: 30.days, dimension: "SERVICE")
        client.get_dimension_values({
          filter:,
          dimension:,
          time_period: {
            start: (Time.now - period).strftime("%Y-%m-%d"),
            end: Time.now.utc.strftime("%Y-%m-%d")
          }
        }).dimension_values
      end

      def filter
        return @filter if @filter

        tag_filters = tags.map do |key, value|
          {
            tags: {
              key: key.to_s,
              values: [ value.to_s ],
              match_options: [ "EQUALS" ]
            }
          }
        end

        @filter = tag_filters.count > 1 ? { and: tag_filters } : tag_filters.first
      end
    end
  end
end
