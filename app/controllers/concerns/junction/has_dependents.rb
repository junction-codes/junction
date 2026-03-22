# frozen_string_literal: true

module Junction
  # Concern for handling dependents for a resource.
  #
  # @todo Explore using a view model to merge the dependents for easier
  #   querying.
  module HasDependents
    extend ActiveSupport::Concern

    # GET /:resource/:id/dependents
    def dependents
      authorize! @entity, to: :show?

      entities, sort_query = dependents_query

      render Views::Shared::Dependents.new(
        dependents: entities,
        pagy: @pagy,
        query: sort_query,
        page_url: ->(page) {
          url_for(
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          url_for(per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          url_for(
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    private

    # Builds and executes a paginated query for dependents.
    #
    # The API query is used for Ransack sorting and filters.
    #
    # @return [Array(Array<Junction::Dependency>, Ransack::Search)] Entity list
    #   and query to use for sorting.
    def dependents_query
      api_query = @entity.api_dependents.ransack(params[:q])
      component_query = @entity.component_dependents.ransack(params[:q])
      resource_query = @entity.resource_dependents.ransack(params[:q])
      api_query.sorts = "name asc" if api_query.sorts.empty?

      @pagy, entities = paginate(merged_dependent_list(
        api_query,
        [ api_query, component_query, resource_query ]
      ))

      [ entities, api_query ]
    end

    # Merges results of the different dependent types and sorts them.
    #
    # @param sort_query [Ransack::Search] Query to used to determine sorting.
    # @param queries [Array<Ransack::Search>] Queries to merge.
    # @return [Array<Junction::Dependency>] Merged and sorted entity list.
    def merged_dependent_list(sort_query, queries)
      sort = sort_query.sorts.first
      entities = queries.map(&:result).flatten
      sorted = entities.sort_by do |entity|
        [ entity.public_send(sort.name).to_s.downcase, entity.name.to_s.downcase ]
      end

      sort.dir == "desc" ? sorted.reverse : sorted
    end
  end
end
