# frozen_string_literal: true

require "pagy"

module Junction
  # Pagination helpers for controllers.
  module Paginatable
    extend ActiveSupport::Concern

    include Pagy::Method

    ALLOWED_PER_PAGE = [ 10, 25, 50, 100 ].freeze
    DEFAULT_PER_PAGE = 10

    private

    # Paginate a collection using Pagy.
    #
    # @param collection [ActiveRecord::Relation] The unpaginated collection.
    # @return [Array(Pagy, ActiveRecord::Relation)] Pagy metadata and the
    #   paginated result.
    def paginate(collection)
      limit = params[:per_page].to_i
      limit = Pagy::OPTIONS[:limit] unless ALLOWED_PER_PAGE.include?(limit)

      pagy(:offset, collection, limit:)
    end
  end
end
