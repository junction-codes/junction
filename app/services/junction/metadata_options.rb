# frozen_string_literal: true

module Junction
  # The tags and labels a listing's entities actually carry for filtering.
  #
  # Read from the scope being listed rather than from the kind as a whole, so
  # a menu never offers a value that would empty the listing.
  class MetadataOptions
    # The max number of items displayed in the menu.
    LIMIT = 50

    # The max number of values one label key offers.
    VALUES_PER_KEY = 20

    # Expanding a row's tags or labels into one row each.
    TAGS_JOIN = "CROSS JOIN LATERAL unnest(tags) AS tag"
    LABELS_JOIN = "CROSS JOIN LATERAL jsonb_each_text(labels) AS pair(key, value)"

    # Initializes the metadata options for a given scope.
    #
    # @param scope [ActiveRecord::Relation] The scope being listed.
    def initialize(scope)
      @scope = scope
    end

    # Tags in use, most used first.
    #
    # @return [Array<String>] The tags.
    def tags
      @tags ||= @scope.reorder(nil)
                      .joins(TAGS_JOIN)
                      .group("tag").order(Arel.sql("COUNT(*) DESC, tag"))
                      .limit(LIMIT).pluck(Arel.sql("tag"))
    end

    # Label keys in use, most used first.
    #
    # Counted over keys rather than read off the pairs. Keys used more often
    # appear higher in the list.
    #
    # @return [Array<String>] The keys.
    def label_keys
      @label_keys ||= @scope.reorder(nil)
                            .joins(LABELS_JOIN)
                            .group("pair.key")
                            .order(Arel.sql("COUNT(*) DESC, pair.key"))
                            .limit(LIMIT)
                            .pluck(Arel.sql("pair.key"))
    end

    # Values in use for a label key.
    #
    # @param key [String] The key.
    # @return [Array<String>] The values.
    def label_values(key)
      label_pairs.fetch(key.to_s, [])
    end

    # Whether or not the scope incudes any tag filters.
    #
    # @return [Boolean] Whether the listing carries any tags.
    def tags?
      tags.any?
    end

    # Whether or not the scope includes any label filters.
    #
    # @return [Boolean] Whether the listing carries any labels.
    def labels?
      label_pairs.any?
    end

    private

    # Every offered key's values.
    #
    # Collected in one pass since the menu renders all of them. Ranked within
    # each key rather than limited overall, so each key gets its own share of
    # the menu.
    #
    # @return [Hash<String, Array<String>>] Values by key.
    def label_pairs
      @label_pairs ||= ranked_values.group_by(&:first)
                                    .transform_values { |rows| rows.map(&:last).uniq }
    end

    # Every key/value pair ranked based on how often it's used.
    #
    # @return [Array<Array(String, String)>] Key and value, most used first.
    def ranked_values
      return [] if label_keys.empty?

      model.base_class.unscoped.from(values_by_use, :ranked)
           .where("ranked.key IN (?)", label_keys)
           .where("ranked.rank <= ?", VALUES_PER_KEY)
           .order(Arel.sql("ranked.uses DESC, ranked.key, ranked.value"))
           .pluck(Arel.sql("ranked.key"), Arel.sql("ranked.value"))
    end

    # Each key/value pair with how often it is used and where that places it
    # among its own key's values.
    #
    # @return [ActiveRecord::Relation] The subquery.
    def values_by_use
      @scope.reorder(nil).joins(LABELS_JOIN)
            .group("pair.key", "pair.value")
            .select(Arel.sql(<<~SQL.squish))
              pair.key AS key, pair.value AS value, COUNT(*) AS uses,
              ROW_NUMBER() OVER (
                PARTITION BY pair.key ORDER BY COUNT(*) DESC, pair.value
              ) AS rank
            SQL
    end

    # @return [Class] The model being listed.
    def model
      @scope.model
    end
  end
end
