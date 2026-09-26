# frozen_string_literal: true

module Junction
  # The tags and labels a listing's entities actually carry for filtering.
  #
  # Read from the scope being listed rather than from the kind as a whole, so
  # a menu never offers a value that would empty the listing.
  class MetadataOptions
    # The most a menu offers. A catalog can carry thousands of distinct tags,
    # and a menu listing them all is not a menu.
    LIMIT = 50

    # The most values one label key offers. Its own budget, so a key with a
    # value per entity -- a build number, a commit -- cannot crowd the other
    # keys out of the menu entirely.
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
    # Counted over keys rather than read off the pairs: a key is offered on
    # how much it is used, not on how few values it has.
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

    # Every offered key's values, in one pass: the menu renders all of them,
    # so a query per key would be a query per row of the key column.
    #
    # Ranked within each key rather than limited overall, so each key gets its
    # own share of the menu.
    #
    # @return [Hash<String, Array<String>>] Values by key.
    def label_pairs
      @label_pairs ||= ranked_values.group_by(&:first)
                                    .transform_values { |rows| rows.map(&:last).uniq }
    end

    # @return [Array<Array(String, String)>] Key and value, most used first.
    def ranked_values
      return [] if label_keys.empty?

      # The base class, unscoped: a kind's own STI condition belongs to the
      # subquery, and repeating it out here would name a table this query has
      # no FROM entry for. Conditions name the subquery for the same reason.
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
