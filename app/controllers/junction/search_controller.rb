# frozen_string_literal: true

module Junction
  # Controller for the global search.
  #
  # No additional authorization checks are performed, as `index_scope_for` will
  # handle the authorization for each searchable model.
  class SearchController < ApplicationController
    include HasOwner
    include Paginatable

    skip_verify_authorized

    SEARCHABLE_MODELS = [ Api, Component, Domain, Resource, System ].freeze
    SORT_FIELDS = %w[name kind].freeze

    # GET /search
    def index
      @query = params[:q].to_s.strip
      sort_field, sort_dir = parse_sort

      full_results = @query.present? ? fetch_models(@query) : []
      sorted = sort_results(full_results, sort_field, sort_dir)

      @pagy, @results = paginate(sorted)

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
      results = query.present? ? fetch_models(query, limit: 2).first(5) : []

      render Views::Search::Autocomplete.new(query:, results:)
    end

    private

    # Fetches matching records across all searchable models.
    #
    # @param query [String] The search query.
    # @param limit [Integer, nil] Per-model result cap (nil = 100).
    # @return [Array<ApplicationRecord>] Flat array of matching records.
    def fetch_models(query, limit: 100)
      pattern = "%#{query}%"

      SEARCHABLE_MODELS.flat_map do |model|
        scope = index_scope_for(model)
        next [] if scope.nil?

        scope .where("name ILIKE :p OR description ILIKE :p", p: pattern)
          .order(:name)
          .limit(limit)
          .to_a
      end
    end

    # Sorts the combined results array.
    #
    # @param results [Array<ApplicationRecord>] Flat results array.
    # @param field [String] Sort field ("name" or "kind").
    # @param direction [String] Sort direction ("asc" or "desc").
    # @return [Array<ApplicationRecord>] Sorted results.
    def sort_results(results, field = "name", direction = "asc")
      sorted = case field
      when "kind" then results.sort_by { |e| [ e.class.model_name.human, e.name ] }
      else results.sort_by(&:name)
      end

      direction == "desc" ? sorted.reverse : sorted
    end

    # Parses and validates the sort params.
    #
    # @return [Array(String, String)] Field and direction.
    def parse_sort
      field, dir = params[:s].to_s.split(" ", 2)
      field = SORT_FIELDS.include?(field) ? field : "name"
      dir = %w[asc desc].include?(dir) ? dir : "asc"

      [ field, dir ]
    end
  end
end
