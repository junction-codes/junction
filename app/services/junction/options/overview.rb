# frozen_string_literal: true

module Junction
  module Options
    # Builds known/other catalog option breakdowns for the options page.
    class Overview
      FieldConfig = Struct.new(:id, :section, :sources, keyword_init: true)
      Source = Struct.new(:model, :column, keyword_init: true)

      FIELDS = [
        FieldConfig.new(
          id: :api_type,
          section: :apis,
          sources: [ Source.new(model: Junction::Api, column: :api_type) ]
        ),
        FieldConfig.new(
          id: :component_type,
          section: :kinds,
          sources: [ Source.new(model: Junction::Component, column: :component_type) ]
        ),
        FieldConfig.new(
          id: :resource_type,
          section: :resources,
          sources: [ Source.new(model: Junction::Resource, column: :resource_type) ]
        ),
        FieldConfig.new(
          id: :domain_type,
          section: :domains,
          sources: [ Source.new(model: Junction::Domain, column: :domain_type) ]
        ),
        FieldConfig.new(
          id: :group_type,
          section: :group_types,
          sources: [ Source.new(model: Junction::Group, column: :group_type) ]
        ),
        FieldConfig.new(
          id: :lifecycle,
          section: :lifecycles,
          sources: [
            Source.new(model: Junction::Api, column: :lifecycle),
            Source.new(model: Junction::Component, column: :lifecycle)
          ]
        )
      ].freeze

      # Builds the breakdowns of known and other options
      #
      # @return [Array<Hash>] Array of option fields.
      def fields
        @fields ||= FIELDS.map { |config| build_field(config) }
      end

      private

      # Builds the breakdown for a single option field.
      #
      # @param config [FieldConfig] Configuration for the field.
      # @return [Hash] The breakdown of known and other options.
      def build_field(config)
        known_options = Junction::CatalogOptions.options.fetch(config.section, {})
        counts = value_counts(config)

        known = known_options.map do |value, attrs|
          count = counts.delete(value.to_s) || 0
          {
            value: value.to_s,
            name: attrs[:name],
            icon: attrs[:icon],
            description: attrs[:description],
            count:
          }
        end

        other = counts.map do |value, count|
          {
            value: value,
            name: value.humanize,
            icon: nil,
            description: nil,
            count:
          }
        end

        other.sort_by! { |row| [ -row[:count], row[:value] ] }

        {
          id: config.id.to_s,
          label: field_label(config),
          known:,
          other:,
          known_total_count: known.sum { |row| row[:count] },
          other_total_count: other.sum { |row| row[:count] },
          total_count: known.sum { |row| row[:count] } + other.sum { |row| row[:count] },
          charts: chart_data(known, other)
        }
      end

      # Builds the counts of values for a single option field.
      #
      # @param config [FieldConfig] Configuration for the field.
      # @return [Hash] The counts of each value for the field.
      def value_counts(config)
        counts = Hash.new(0)
        config.sources.each do |source|
          source.model.group(source.column).count.each do |raw_value, count|
            value = raw_value.to_s.strip
            next if value.blank?

            counts[value] += count
          end
        end

        counts
      end

      # Builds the label for a single option field.
      #
      # @param config [FieldConfig] Configuration for the field.
      # @return [String] The label for the field.
      def field_label(config)
        t(".field_labels.#{config.id}")
      end

      # Builds the chart data for a single option field.
      #
      # @param known [Array<Hash>] Known options.
      # @param other [Array<Hash>] Observed options.
      # @return [Hash] The chart data.
      def chart_data(known, other)
        value_breakdown = (known + other).sort_by do |row|
          [ -row[:count], row[:name] ]
        end.first(5)

        {
          known_vs_other: {
            t(".known") => known.sum { |row| row[:count] },
            t(".other") => other.sum { |row| row[:count] }
          },
          value_breakdown: value_breakdown.to_h { |row| [ row[:name], row[:count] ] }
        }
      end

      def t(key, options = {})
        I18n.t(key, **options.merge(scope: "junction.views.options.index"))
      end
    end
  end
end
