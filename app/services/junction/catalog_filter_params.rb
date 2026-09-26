# frozen_string_literal: true

module Junction
  # The query parameters a filtered catalog listing is reached by.
  #
  # A filtered view is a place: it has to survive being pasted into a ticket,
  # so everything the listing is showing rides in the URL. The rules for what
  # a link carries live here.
  #
  # Every change returns a new set rather than mutating this one, so a link
  # can't alter the view it was rendered from.
  class CatalogFilterParams
    attr_reader :query, :added, :per_page, :tab, :metadata

    # Initializes a new set of catalog filter parameters.
    #
    # @param query [Hash] Ransack predicates and their values.
    # @param added [Array<String>] Predicates on the bar without a value yet.
    # @param per_page [Integer] Page size, when not the default.
    # @param tab [String] The currently open tab, when not the default.
    # @param metadata [Junction::MetadataFilters] Tag and label filters.
    def initialize(query: {}, added: [], per_page: nil, tab: nil, metadata: nil)
      @query = query.to_h.symbolize_keys
      @added = Array(added).map(&:to_s).uniq
      @tab = tab.presence
      @metadata = metadata || MetadataFilters.new

      # The default page size is what a bare URL already means.
      @per_page = per_page if per_page && per_page != Paginatable::DEFAULT_PER_PAGE
    end

    # The parameters themselves, with the empty ones left out.
    #
    # @return [Hash] The parameters.
    def to_h
      { q: query.compact_blank.presence,
        filters: added.join(",").presence,
        per_page:,
        tab: (tab if carry_tab?) }.compact.merge(metadata.to_params)
    end

    # The same parameters as flat `name => value` pairs, for a form that has to
    # carry them as hidden fields.
    #
    # @param except [Symbol] A Ransack predicate the form owns itself.
    # @return [Array<Array(String, String)>] The pairs, in render order.
    def to_fields(except: nil)
      fields = []
      fields << [ "tab", tab ] if carry_tab?
      fields << [ "per_page", per_page ] if per_page
      fields << [ "filters", added.join(",") ] if added.any?
      metadata.tags.each { |tag| fields << [ "tags[]", tag ] }
      metadata.labels.each { |key, value| fields << [ "labels[#{key}]", value ] }
      metadata.unset.each { |key| fields << [ "labels_unset[]", key ] }
      query.except(except).each do |key, value|
        fields << [ "q[#{key}]", value ] if value.present?
      end

      fields
    end

    # One filter set to a value, or cleared when the value is nil.
    #
    # Choosing a value for the filter a tab stands for leaves the tab. The tab
    # forces its own value, so staying would be asking for two at once.
    #
    # @param predicate [String] The Ransack predicate.
    # @param value [Object, nil] The value, or nil to clear it.
    # @param implied [String] The predicate the current tab forces, if any.
    # @return [CatalogFilterParams] The new set.
    def choose(predicate, value, implied: nil)
      leaving = implied == predicate

      merge(query: query.merge(predicate.to_sym => value),
            added: value.nil? ? added - [ predicate ] : added,
            tab: (leaving ? nil : tab))
    end

    # One filter put on the bar without a value yet.
    #
    # @param predicate [String] The Ransack predicate.
    # @return [CatalogFilterParams] The new set.
    def adding(predicate)
      merge(added: added + [ predicate ])
    end

    # Adds metadata filters to the params.
    #
    # @param tags [Array<String>] Tags to filter on.
    # @param labels [Hash] Label key to the value it must hold.
    # @param unset [Array<String>] Label keys that must be absent.
    # @return [CatalogFilterParams] The new set.
    def with_metadata(tags: metadata.tags, labels: metadata.labels,
                      unset: metadata.unset)
      merge(metadata: MetadataFilters.new(tags:, labels:, unset:))
    end

    # Everything dropped, including the bar itself.
    #
    # @return [CatalogFilterParams] The new set.
    def cleared
      merge(query: {}, added: [], metadata: MetadataFilters.new)
    end

    # Whether or not any filters are currently applied.
    #
    # @return [Boolean] Whether anything is being filtered.
    def any?
      query.compact_blank.any? || added.any? || metadata.any?
    end

    private

    # Whether or not the tab should be included in the URL.
    #
    # @return [Boolean] Whether the tab belongs in the URL.
    def carry_tab?
      tab.present? && tab != CatalogTabs::DEFAULT
    end

    def merge(**changes)
      self.class.new(query:, added:, per_page:, tab:, metadata:, **changes)
    end
  end
end
