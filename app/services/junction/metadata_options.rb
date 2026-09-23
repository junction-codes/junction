# frozen_string_literal: true

module Junction
  # The tags and labels a listing's entities actually carry for filtering.
  #
  # Read from the scope being listed rather than from the kind as a whole, so
  # a menu never offers a value that would empty the listing.
  class MetadataOptions
    # The max number of items displayed in the menu.
    LIMIT = 50

    # Every kind lives in one table, so these are literals rather than
    # interpolated table names. Nothing here is built from input, and there is
    # no interpolation for a reader to have to rule out. `Junction::Entity`
    # naming another table is a spec failure.
    TABLE = "junction_entities"
    TAGS_FROM = "#{TABLE}, unnest(tags) AS tag".freeze
    LABELS_FROM = "#{TABLE}, jsonb_each_text(labels) AS pair(key, value)".freeze

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
                      .from(TAGS_FROM)
                      .group("tag").order(Arel.sql("COUNT(*) DESC, tag"))
                      .limit(LIMIT).pluck(Arel.sql("tag"))
    end

    # Label keys in use, most used first.
    #
    # @return [Array<String>] The keys.
    def label_keys
      label_pairs.keys
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

    # Every key and its values in one pass, since a menu shows both.
    #
    # @return [Hash<String, Array<String>>] Values by key.
    def label_pairs
      @label_pairs ||= @scope.reorder(nil)
                             .from(LABELS_FROM)
                             .group("pair.key", "pair.value")
                             .order(Arel.sql("COUNT(*) DESC, pair.key, pair.value"))
                             .limit(LIMIT)
                             .pluck(Arel.sql("pair.key"), Arel.sql("pair.value"))
                             .group_by(&:first)
                             .transform_values { |rows| rows.map(&:last).uniq }
    end
  end
end
