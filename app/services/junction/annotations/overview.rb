# frozen_string_literal: true

module Junction
  module Annotations
    # Builds annotation usage breakdowns for the annotations overview page.
    class Overview
      EntityType = Struct.new(:id, :model, keyword_init: true)

      # Maximum number of distinct values charted for a single annotation key.
      # Remaining values are aggregated into a single "other" bucket so that
      # high-cardinality annotations can't produce an unbounded chart.
      VALUE_CHART_LIMIT = 10

      # Kinds that carry annotations, from the registry. Locations and
      # templates are excluded until they are annotated in practice.
      ANNOTATED_SCOPES = %i[api component domain group resource system user].freeze

      # Entity types included in the overview.
      #
      # @return [Array<EntityType>]
      def self.entity_types
        ANNOTATED_SCOPES.filter_map do |scope|
          kind = Junction::Kinds.by_scope(scope)
          EntityType.new(id: kind.context, model: kind.model) if kind
        end
      end

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

        entity_rows = self.class.entity_types.filter_map do |entity_type|
          rows = value_rows_for(entity_type.model, key)
          next if rows.empty?

          {
            type_id: entity_type.id,
            known_for_type: known_for_model?(entity_type.model, key),
            count: rows.sum { |row| row[:count] },
            top_value: rows.max_by { |row| row[:count] }&.fetch(:value)
          }
        end

        {
          id: slug_for(key),
          label: key,
          known: known_for_any_type?(key),
          title: known_title_for(key),
          total_count: total_count_for_key(key),
          entity_types: entity_rows,
          charts: {
            value_breakdown: value_breakdown_chart(key),
            by_entity_type: entity_rows.to_h { |row| [ entity_label(row[:type_id]), row[:count] ] }
          }
        }
      end

      # Lightweight rows for entity-type vertical tabs.
      #
      # @return [Array<Hash>] List of entity types and their annotation
      #   metadata.
      def entity_type_tabs
        self.class.entity_types.map do |entity_type|
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
        entity_type = self.class.entity_types.find { |type| type.id == id }
        return nil unless entity_type

        known_annotations = PluginRegistry.annotations_for(entity_type.model)
        known_keys = known_annotations.keys
        rows_by_key = value_rows_by_key_for(entity_type.model)

        known_rows = known_keys.map do |key|
          rows = rows_by_key.fetch(key, [])
          {
            key:,
            title: known_annotations.dig(key, :title),
            count: rows.sum { |row| row[:count] },
            top_value: rows.max_by { |row| row[:count] }&.fetch(:value)
          }
        end

        other_rows = rows_by_key.except(*known_keys).map do |key, rows|
          {
            key:,
            count: rows.sum { |row| row[:count] },
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
            top_keys: top_keys.to_h { |row| [ row[:key], row[:count] ] }
          }
        }
      end

      # Converts an annotation key to a URL slug.
      #
      # Slugs are unique across all known annotation keys. Keys that would share
      # a slug (e.g. +team.name+ and +team/name+) are disambiguated with a
      # numeric suffix.
      #
      # @param key [String] Key for the annotation.
      # @return [String] URL-friendly slug for the annotation key.
      def slug_for(key)
        slugs_by_key.fetch(key.to_s) { base_slug(key) }
      end

      # Resolves a URL slug to an annotation key.
      #
      # @param slug [String] URL-friendly slug for the annotation key.
      # @return [String, nil] The original annotation key, or nil if not found.
      def key_for_slug(slug)
        keys_by_slug[slug.to_s]
      end

      private

      # Maps each annotation key to its unique slug.
      #
      # @return [Hash<String, String>] Map of annotation key to slug.
      def slugs_by_key
        @slugs_by_key ||= keys_by_slug.invert
      end

      # Maps each unique slug to its annotation key.
      #
      # @return [Hash<String, String>] Map of slug to annotation key.
      def keys_by_slug
        @keys_by_slug ||= annotation_keys.each_with_object({}) do |key, map|
          map[unique_slug(base_slug(key), map)] = key
        end
      end

      # Builds the unqualified slug for an annotation key.
      #
      # @param key [String] Key for the annotation.
      # @return [String] URL-friendly slug, which may not be unique.
      def base_slug(key)
        key.to_s.parameterize.presence || "annotation"
      end

      # Suffixes a slug until it no longer collides with an existing one.
      #
      # @param slug [String] The desired slug.
      # @param taken [Hash] Map of slugs already in use.
      # @return [String] A slug that is not yet in use.
      def unique_slug(slug, taken)
        return slug unless taken.key?(slug)

        suffix = 2
        suffix += 1 while taken.key?("#{slug}-#{suffix}")
        "#{slug}-#{suffix}"
      end

      # Collects all of the unique annotation keys.
      #
      # @return [Array<String>] List of unique annotation keys.
      def annotation_keys
        @annotation_keys ||= begin
          keys = key_counts_by_type.values.flat_map(&:keys)
          keys.concat(registered_keys)
          keys.uniq.sort
        end
      end

      # Collects all of the known annotation keys.
      #
      # @return [Array<String>] List of known annotation keys.
      def registered_keys
        self.class.entity_types.flat_map do |entity_type|
          PluginRegistry.annotations_for(entity_type.model).keys
        end.uniq
      end

      # Table holding every entity.
      #
      # Every kind shares it, so these queries must constrain by kind. The name
      # is taken from the model rather than interpolated from a caller-supplied
      # value.
      #
      # @return [String] The quoted table name.
      def entities_table
        Junction::Entity.quoted_table_name
      end

      # Counts the annotated records of an entity type, per annotation key.
      #
      # Values are not expanded, so the result is bounded by the number of
      # distinct keys rather than the number of distinct key/value pairs.
      #
      # @param model [Class] The model class for the entity type.
      # @return [Hash<String, Integer>] Map of annotation key to record count.
      def key_counts(model)
        sql = model.sanitize_sql_array([ <<~SQL.squish, { kind: model.sti_name } ])
          SELECT key, COUNT(*) AS count
          FROM #{entities_table} entities, jsonb_each_text(entities.annotations)
          WHERE entities.kind = :kind
          GROUP BY key
        SQL

        model.connection.select_all(sql).to_h do |row|
          [ row["key"], row["count"].to_i ]
        end
      end

      # Counts the annotated records of an entity type, per key and value.
      #
      # @param model [Class] The model class for the entity type.
      # @param key [String] Restricts the query to a single annotation key.
      # @return [Array<Hash>] List of key/value counts for the entity type.
      def key_value_counts(model, key: nil)
        binds = { kind: model.sti_name }
        conditions = [ "entities.kind = :kind" ]

        if key
          conditions << "key = :key"
          binds[:key] = key
        end

        sql = model.sanitize_sql_array([ <<~SQL.squish, binds ])
          SELECT key, value, COUNT(*) AS count
          FROM #{entities_table} entities, jsonb_each_text(entities.annotations)
          WHERE #{conditions.join(' AND ')}
          GROUP BY key, value
        SQL

        model.connection.select_all(sql).map do |row|
          {
            key: row["key"],
            value: row["value"].to_s,
            count: row["count"].to_i
          }
        end
      end

      # Value counts for a single entity type and annotation key.
      #
      # @param model [Class] The model class for the entity type.
      # @param key [String] Key for the annotation.
      # @return [Array<Hash>] List of value/count pairs, sorted by count
      #   descending, then value.
      def value_rows_for(model, key)
        @value_rows_for ||= {}
        @value_rows_for[[ model, key ]] ||=
          merge_value_rows(key_value_counts(model, key:))
      end

      # Value counts for every annotation key of a single entity type.
      #
      # @param model [Class] The model class for the entity type.
      # @return [Hash<String, Array<Hash>>] Map of annotation key to its
      #   value/count pairs, sorted by count descending, then value.
      def value_rows_by_key_for(model)
        @value_rows_by_key_for ||= {}
        @value_rows_by_key_for[model] ||=
          key_value_counts(model).group_by { |row| row[:key] }
                                 .transform_values { |rows| merge_value_rows(rows) }
      end

      # Value counts for an annotation key across every entity type.
      #
      # @param key [String] Key for the annotation.
      # @return [Array<Hash>] List of value/count pairs, sorted by count
      #   descending, then value.
      def value_rows_for_key(key)
        @value_rows_for_key ||= {}
        @value_rows_for_key[key] ||= merge_value_rows(
          self.class.entity_types.flat_map { |entity_type| value_rows_for(entity_type.model, key) }
        )
      end

      # Groups rows by value, summing their counts.
      #
      # @param rows [Array<Hash>] Rows with +:value+ and +:count+.
      # @return [Array<Hash>] List of value/count pairs, sorted by count
      #   descending, then value.
      def merge_value_rows(rows)
        rows.group_by { |row| row[:value] }
            .map { |value, grouped| { value:, count: grouped.sum { |row| row[:count] } } }
            .sort_by { |row| [ -row[:count], row[:value] ] }
      end

      # Builds the value breakdown chart data for an annotation key.
      #
      # Only the most used values are charted, the rest are summed into a single
      # bucket so that high-cardinality annotations stay renderable.
      #
      # @param key [String] Key for the annotation.
      # @return [Hash<String, Integer>] Map of annotation value to record count.
      def value_breakdown_chart(key)
        rows = value_rows_for_key(key)
        return rows.to_h { |row| [ row[:value], row[:count] ] } if rows.size <= VALUE_CHART_LIMIT

        charted = rows.first(VALUE_CHART_LIMIT)
        remainder = rows.drop(VALUE_CHART_LIMIT).sum { |row| row[:count] }
        charted.to_h { |row| [ row[:value], row[:count] ] }
               .merge(t(".other_values", count: rows.size - VALUE_CHART_LIMIT) => remainder)
      end

      # Sums the total number of records annotated with a given key.
      #
      # @param key [String] Key for the annotation.
      # @return [Integer] Total count of records annotated with the key.
      def total_count_for_key(key)
        total_counts_by_key.fetch(key, 0)
      end

      # Sums the per-entity-type key counts for every annotation key.
      #
      # @return [Hash<String, Integer>] Map of annotation key to total count.
      def total_counts_by_key
        @total_counts_by_key ||= begin
          totals = Hash.new(0)
          key_counts_by_type.each_value do |counts|
            counts.each { |key, count| totals[key] += count }
          end
          totals
        end
      end

      # Counts the records per entity type and annotation key.
      #
      # @return [Hash<String, Hash>] Map of entity type id to a map of
      #   annotation key and total count.
      def key_counts_by_type
        @key_counts_by_type ||= self.class.entity_types.to_h do |entity_type|
          [ entity_type.id, key_counts(entity_type.model) ]
        end
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
        self.class.entity_types.any? { |entity_type| known_for_model?(entity_type.model, key) }
      end

      # Finds the display title registered for a known annotation key.
      #
      # @param key [String] Key for the annotation.
      # @return [String, nil] Registered title for the key, or nil if the key
      #   isn't known for any entity type.
      def known_title_for(key)
        self.class.entity_types.lazy.filter_map do |entity_type|
          PluginRegistry.annotations_for(entity_type.model).dig(key, :title)
        end.first
      end

      # Resolves the human-readable label for an entity type.
      #
      # @param id [String] Entity type tab id.
      # @return [String] Human-readable, pluralized model name.
      def entity_label(id)
        entity_type = self.class.entity_types.find { |type| type.id == id }
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
