# frozen_string_literal: true

module Junction
  # The tab strip above a catalog listing.
  #
  # Each tab is a saved shape of the same question, so a tab is a scope over the
  # listing's own relation rather than a separate query path. That keeps the
  # tabs honest; whatever the listing wouldn't show a tab can't show either.
  #
  # Available tabs are determined by the kind being listed.
  class CatalogTabs
    DEFAULT = "all"

    # Every available tab, in display order.
    NAMES = %w[all mine production recent].freeze

    # The tabs that carry a count. `recent` is a sort rather than a filter, so
    # counting it would be repetitive.
    COUNTED = %w[all mine production].freeze

    # The sort a tab implies, for those that have one.
    SORTS = { "recent" => "updated_at desc" }.freeze

    # The lifecycle the production tab means.
    PRODUCTION = "production"

    # The filter a tab holds, as `predicate => value`. `:viewer` marks a
    # value with no single option behind it, `mine` matches any of the
    # viewer's groups as well as the viewer.
    IMPLIED = {
      "mine" => [ "owner_id_eq", :viewer ],
      "production" => [ "lifecycle_eq", PRODUCTION ]
    }.freeze

    attr_reader :names

    # Initializes the tab strip.
    #
    # @param relation [ActiveRecord::Relation] The listing's unfiltered
    #   relation, already scoped to what the user may read.
    # @param kind [Junction::Kind] The kind being listed.
    # @param user [Junction::User] The current user.
    def initialize(relation:, kind:, user:)
      @relation = relation
      @kind = kind
      @user = user
      @names = NAMES.select { |name| offers?(name) }
    end

    # Narrows the relation to one tab.
    #
    # @param name [String] The tab.
    # @return [ActiveRecord::Relation] The narrowed relation.
    def scope(name)
      case resolve(name)
      when "mine" then @relation.where(owner_id: owner_ids)
      when "production" then @relation.where(lifecycle: PRODUCTION)
      else @relation
      end
    end

    # The sort a tab implies, if it has one.
    #
    # @param name [String] The tab.
    # @return [String, nil] The Ransack sort.
    def sorts(name)
      SORTS[resolve(name)]
    end

    # How many entities each counted tab would show.
    #
    # One query with conditional aggregates rather than one per tab. The tabs
    # differ only in their predicate, and they all sit over the same relation.
    #
    # @return [Hash{String => Integer}] Counts keyed by tab name.
    def counts
      @counts ||= begin
        counted = names & COUNTED
        row = Array(@relation.unscope(:order, :select).pick(*selects(counted)))

        counted.zip(row.map(&:to_i)).to_h
      end
    end

    # The filter a tab holds.
    #
    # @param name [String] The tab.
    # @return [Array(String, Object), nil] The predicate and its value, or nil
    #   for a tab that filters nothing.
    def implied_filter(name)
      IMPLIED[resolve(name)]
    end

    # Resolve a tab name to an available one.
    #
    # Falls back to the default when the requested tab isn't available.
    #
    # @param name [String] The tab.
    # @return [String] The resolved tab.
    def resolve(name)
      names.include?(name) ? name : DEFAULT
    end

    private

    # Whether or not a tab is available based on the current kind.
    #
    # @param name [String] The tab.
    # @return [Boolean] Whether or not the tab is available.
    def offers?(name)
      case name
      when "mine" then @kind.ownable? && owner_ids.any?
      when "production" then lifecycle?
      else true
      end
    end

    # Whether or not the kind has a lifecycle attribute.
    #
    # @return [Boolean] Whether the kind shows a lifecycle.
    def lifecycle?
      @kind.model.index_columns.any? { |type, _| type == :lifecycle }
    end

    # Full list of owner IDs that make up the current user's ownership tree.
    #
    # @return [Array<Integer>] Group and user IDs.
    def owner_ids
      @owner_ids ||= @user&.owner_ids || []
    end

    # Collects the SQL aggregates for the given tabs.
    #
    # @param counted [Array<String>] The tabs to count.
    # @return [Array<Arel::Nodes::SqlLiteral>] One aggregate per tab.
    def selects(counted)
      counted.map { |name| select_for(name) }
    end

    # The aggregate for a single tab.
    #
    # Each is a whole statement handed to `sanitize_sql_array` rather than a
    # predicate interpolated into a template. The values are the only dynamic
    # part.
    #
    # @param name [String] The tab.
    # @return [Arel::Nodes::SqlLiteral] The aggregate.
    def select_for(name)
      case name
      when "mine" then sql([ "COUNT(*) FILTER (WHERE owner_id IN (?))", owner_ids ])
      when "production"
        sql([ "COUNT(*) FILTER (WHERE lifecycle = ?)", PRODUCTION ])
      else Arel.sql("COUNT(*)")
      end
    end

    # Sanitizes a SQL fragment for use in an aggregate.
    #
    # @param fragment [Array] A `sanitize_sql_array` fragment.
    # @return [Arel::Nodes::SqlLiteral] The sanitized SQL.
    def sql(fragment)
      Arel.sql(Junction::Entity.sanitize_sql_array(fragment))
    end
  end
end
