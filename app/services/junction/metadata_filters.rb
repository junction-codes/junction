# frozen_string_literal: true

module Junction
  # The tag and label filters for a catalog listing.
  #
  # Tags are a Postgres array and labels a jsonb map, so neither is an
  # attribute Ransack can put a predicate on. They ride in the URL beside `q`
  # as `tags[]`, `labels[key]` and `labels_unset[]`, and this turns those into
  # scopes.
  #
  # Every tag and every label narrows the listing further, acting as a logical
  # `AND``.
  class MetadataFilters
    attr_reader :tags, :labels, :unset

    # Initializes the filters.
    #
    # @param tags [Array<String>] All tags the entity must carry.
    # @param labels [Hash, ActionController::Parameters] Labels the entity must
    #   have, keyed by label key to the required value.
    # @param unset [Array<String>] Label keys the entity must not carry.
    def initialize(tags: nil, labels: nil, unset: nil)
      @tags = clean_list(tags)
      @labels = clean_pairs(labels)
      @unset = clean_list(unset) - @labels.keys
    end

    # Applies the filters to a scope.
    #
    # @param scope [ActiveRecord::Relation] The scope being listed.
    # @return [ActiveRecord::Relation] The narrowed scope.
    def apply(scope)
      scope = scope.tagged_with(*tags) if tags.any?
      labels.each { |key, value| scope = scope.labeled_with(key, value) }
      unset.each { |key| scope = scope.without_label(key) }

      scope
    end

    # Whether there are any metadata filters applied.
    #
    # @return [Boolean] Whether anything is being filtered.
    def any?
      tags.any? || labels.any? || unset.any?
    end

    # The filters as URL parameters, so a link can carry them.
    #
    # @return [Hash] The parameters, without the empty ones.
    def to_params
      { tags: tags.presence, labels: labels.presence,
        labels_unset: unset.presence }.compact
    end

    private

    def clean_list(value)
      return [] if value.is_a?(Hash) || value.respond_to?(:to_unsafe_h)

      Array(value).map { |item| item.to_s.strip }.compact_blank.uniq
    end

    # Strip any values that aren't valid filter pairs.
    def clean_pairs(value)
      pairs = value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
      return {} unless pairs.is_a?(Hash)

      pairs.filter_map do |key, item|
        key = key.to_s.strip
        item = item.to_s.strip
        [ key, item ] if key.present? && item.present?
      end.to_h
    end
  end
end
