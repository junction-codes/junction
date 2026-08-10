# frozen_string_literal: true

module Junction
  module Annotations
    # Builds annotation usage breakdowns for the annotations overview page.
    class Overview
      EntityType = Struct.new(:id, :model, keyword_init: true)

      ENTITY_TYPES = [
        EntityType.new(id: "apis", model: Junction::Api),
        EntityType.new(id: "components", model: Junction::Component),
        EntityType.new(id: "groups", model: Junction::Group),
        EntityType.new(id: "resources", model: Junction::Resource),
        EntityType.new(id: "users", model: Junction::User)
      ].freeze

      # Lightweight rows for annotation-key vertical tabs.
      #
      # @return [Array<Hash>]
      def annotation_key_tabs
        annotation_keys.map do |key|
          {
            id: slug_for(key),
            label: key,
            total_count: total_count_for_key(key)
          }
        end
      end

      # Full panel data for one annotation key.
      #
      # @param slug [String] URL-safe annotation key slug.
      # @return [Hash, nil] Annotation panel data, or null if the slug doesn't
      #   exist.
      def annotation_key_detail(slug)
        key = key_for_slug(slug)
        return nil if key.blank?

        entity_rows = ENTITY_TYPES.filter_map do |entity_type|
          rows = rows_for(entity_type.model, key)
          next if rows.empty?

          {
            type_id: entity_type.id,
            known_for_type: known_for_model?(entity_type.model, key),
            count: rows.sum { |row| row[:count] },
            top_value: rows.max_by { |row| row[:count] }&.fetch(:value)
          }
        end

        value_rows = value_rows_for_key(key)
        {
          id: slug_for(key),
          label: key,
          known: known_for_any_type?(key),
          title: known_title_for(key),
          total_count: total_count_for_key(key),
          entity_types: entity_rows,
          charts: {
            value_breakdown: value_rows.to_h { |row| [ row[:value], row[:count] ] },
            by_entity_type: entity_rows.to_h { |row| [ entity_label(row[:type_id]), row[:count] ] }
          }
        }
      end

      # Lightweight rows for entity-type vertical tabs.
      #
      # @return [Array<Hash>] List of entity types and their annotation
      #   metadata.
      def entity_type_tabs
        ENTITY_TYPES.map do |entity_type|
          count = annotated_record_count(entity_type.model)
          {
            id: entity_type.id,
            label: entity_label(entity_type.id),
            total_count: count
          }
        end
      end

      # Full panel data for one entity type.
      #
      # @param id [String] Entity type tab id.
      # @return [Hash, nil] Entity type panel data, or null if the id doesn't
      #   exist.
      def entity_type_detail(id)
        entity_type = ENTITY_TYPES.find { |type| type.id == id }
        return nil unless entity_type

        known_keys = PluginRegistry.annotations_for(entity_type.model).keys
        key_counts = key_counts_for_model(entity_type.model)
        known_rows = known_keys.map do |key|
          rows = rows_for(entity_type.model, key)
          {
            key:,
            title: PluginRegistry.annotations_for(entity_type.model).dig(key, :title),
            count: rows.sum { |row| row[:count] },
            top_value: rows.max_by { |row| row[:count] }&.fetch(:value)
          }
        end

        other_rows = key_counts.except(*known_keys).map do |key, count|
          rows = rows_for(entity_type.model, key)
          {
            key:,
            count:,
            top_value: rows.max_by { |row| row[:count] }&.fetch(:value)
          }
        end
        other_rows.sort_by! { |row| [ -row[:count], row[:key] ] }

        known_total = known_rows.sum { |row| row[:count] }
        other_total = other_rows.sum { |row| row[:count] }
        top_keys = (known_rows + other_rows).sort_by { |row| [ -row[:count], row[:key] ] }.first(5)

        {
          id: entity_type.id,
          label: entity_label(entity_type.id),
          total_count: annotated_record_count(entity_type.model),
          known: known_rows,
          other: other_rows,
          charts: {
            known_vs_other: {
              t(".known") => known_total,
              t(".other") => other_total
            },
            value_breakdown: top_keys.to_h { |row| [ row[:key], row[:count] ] }
          }
        }
      end

      # Converts an annotation key to a URL slug.
      #
      # @param key [String] Key for the annotation.
      # @return [String] URL-friendly slug for the annotation key.
      def slug_for(key)
        key.to_s.tr("./", "--")
      end

      # Resolves a URL slug to an annotation key.
      #
      # @param slug [String] URL-friendly slug for the annotation key.
      # @return [String, nil] The original annotation key, or nil if not found.
      def key_for_slug(slug)
        annotation_keys.find { |key| slug_for(key) == slug }
      end

      private

      # Collects all of the unique annotation keys.
      #
      # @return [Array<String>] List of unique annotation keys.
      def annotation_keys
        @annotation_keys ||= begin
          keys = raw_rows.map { |row| row[:key] }
          keys.concat(registered_keys)
          keys.uniq.sort
        end
      end

      # Collects all of the known annotation keys.
      #
      # @return [Array<String>] List of known annotation keys.
      def registered_keys
        ENTITY_TYPES.flat_map do |entity_type|
          PluginRegistry.annotations_for(entity_type.model).keys
        end.uniq
      end

      # Collects all of the raw annotation rows.
      #
      # @return [Array<Hash>] List of raw annotation rows.
      def raw_rows
        @raw_rows ||= ENTITY_TYPES.flat_map do |entity_type|
          key_value_counts(entity_type.model).map do |row|
            row.merge(entity_type_id: entity_type.id)
          end
        end
      end

      # Collects the key-value counts for a given entity type.
      #
      # @param model [Class] The model class for the entity type.
      # @return [Array<Hash>] List of key-value counts for the entity type.
      def key_value_counts(model)
        sql = <<~SQL.squish
          SELECT key, value, COUNT(*) AS count
          FROM #{model.table_name}, jsonb_each(COALESCE(annotations, '{}'::jsonb))
          GROUP BY key, value
        SQL

        model.connection.select_all(sql).map do |row|
          {
            key: row["key"],
            value: row["value"],
            count: row["count"].to_i
          }
        end
      end

      # Filters the raw rows to those for a given key and model.
      #
      # @param model [Class] The model class for the entity type.
      # @param key [String] Key for the annotation.
      # @return [Array<Hash>] List of raw rows matching the key and model.
      def rows_for(model, key)
        raw_rows.select do |row|
          row[:key] == key && row_for_model?(row, model)
        end
      end

      # Checks whether a raw row belongs to the given model.
      #
      # @param row [Hash] A raw annotation row.
      # @param model [Class] The model class for the entity type.
      # @return [Boolean] Whether the row's entity type matches the model.
      def row_for_model?(row, model)
        entity_type = ENTITY_TYPES.find { |type| type.model == model }
        row[:entity_type_id] == entity_type.id
      end

      # Sums the total number of records annotated with a given key.
      #
      # @param key [String] Key for the annotation.
      # @return [Integer] Total count of records annotated with the key.
      def total_count_for_key(key)
        value_rows_for_key(key).sum { |row| row[:count] }
      end

      # Groups the raw rows for a key by value, summing their counts.
      #
      # @param key [String] Key for the annotation.
      # @return [Array<Hash>] List of value/count pairs, sorted by count
      #   descending, then value.
      def value_rows_for_key(key)
        raw_rows.select { |row| row[:key] == key }
                .group_by { |row| row[:value] }
                .map do |value, rows|
          { value:, count: rows.sum { |row| row[:count] } }
        end
                .sort_by { |row| [ -row[:count], row[:value] ] }
      end

      # Groups the raw rows for a model by key, summing their counts.
      #
      # @param model [Class] The model class for the entity type.
      # @return [Hash] Map of annotation key to total count for the model.
      def key_counts_for_model(model)
        raw_rows.select { |row| row_for_model?(row, model) }
                .group_by { |row| row[:key] }
                .transform_values { |rows| rows.sum { |row| row[:count] } }
      end

      # Counts the records for a model that have at least one annotation.
      #
      # @param model [Class] The model class for the entity type.
      # @return [Integer] Count of annotated records for the model.
      def annotated_record_count(model)
        model.where("COALESCE(annotations, '{}'::jsonb) != '{}'::jsonb").count
      end

      # Checks whether a key is a known annotation for a given model.
      #
      # @param model [Class] The model class for the entity type.
      # @param key [String] Key for the annotation.
      # @return [Boolean] Whether the key is registered as known for the model.
      def known_for_model?(model, key)
        PluginRegistry.annotations_for(model).key?(key)
      end

      # Checks whether a key is known for any entity type.
      #
      # @param key [String] Key for the annotation.
      # @return [Boolean] Whether the key is registered as known for any
      #   entity type.
      def known_for_any_type?(key)
        ENTITY_TYPES.any? { |entity_type| known_for_model?(entity_type.model, key) }
      end

      # Finds the display title registered for a known annotation key.
      #
      # @param key [String] Key for the annotation.
      # @return [String, nil] Registered title for the key, or nil if the key
      #   isn't known for any entity type.
      def known_title_for(key)
        ENTITY_TYPES.lazy.filter_map do |entity_type|
          PluginRegistry.annotations_for(entity_type.model).dig(key, :title)
        end.first
      end

      # Resolves the human-readable label for an entity type.
      #
      # @param id [String] Entity type tab id.
      # @return [String] Human-readable, pluralized model name.
      def entity_label(id)
        entity_type = ENTITY_TYPES.find { |type| type.id == id }
        entity_type.model.model_name.human(count: 2)
      end

      # Translates a key scoped to the annotations overview view.
      #
      # @param key [String] Relative translation key.
      # @param options [Hash] Additional I18n interpolation options.
      # @return [String] Translated string.
      def t(key, options = {})
        I18n.t(key, **options.merge(scope: "junction.views.annotations.index"))
      end
    end
  end
end
