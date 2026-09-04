# frozen_string_literal: true

module Junction
  # Controller for the global search.
  #
  # No additional authorization checks are performed, as `entity_scope_for`
  # restricts the relation to kinds the user may read.
  class SearchController < ApplicationController
    include ReadScoped
    include Paginatable

    skip_verify_authorized

    SORT_FIELDS = %w[kind title].freeze

    # GET /search
    def index
      @query = params[:q].to_s.strip
      sort_field, sort_dir = parse_sort

      @pagy, @results = paginate(sorted_results(sort_field, sort_dir))

      render Views::Search::Index.new(
        query: @query,
        results: @results,
        pagy: @pagy,
        sort_field:,
        sort_dir:
      )
    end

    # GET /search/autocomplete
    def autocomplete
      query = params[:q].to_s.strip
      results = query.present? ? matching_entities(query).order(:title).limit(5) : []

      render Views::Search::Autocomplete.new(query:, results:)
    end

    private

    # Ordered relation of entities matching the query.
    #
    # Sorting and paging happen in SQL. Sorting by kind orders on the
    # discriminator, so results group by kind in storage order rather than by
    # translated name.
    #
    # @param field [String] Sort field ("title" or "kind").
    # @param direction [String] Sort direction ("asc" or "desc").
    # @return [ActiveRecord::Relation] The sorted relation.
    def sorted_results(field, direction)
      return Entity.none if @query.blank?

      matching_entities(@query).order(field => direction, :title => :asc)
    end

    # Entities the user may read whose title or description matches.
    #
    # @param query [String] The search query.
    # @return [ActiveRecord::Relation] The matching entities.
    def matching_entities(query)
      entity_scope_for(Junction::Kinds.catalog)
        .where("title ILIKE :p OR description ILIKE :p", p: "%#{query}%")
    end

    # Parses and validates the sort params.
    #
    # @return [Array(String, String)] Field and direction.
    def parse_sort
      field, dir = params[:s].to_s.split(" ", 2)
      field = SORT_FIELDS.include?(field) ? field : "title"
      dir = %w[asc desc].include?(dir) ? dir : "asc"

      [ field, dir ]
    end
  end
end
