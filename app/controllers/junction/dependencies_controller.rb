# frozen_string_literal: true

module Junction
  # Controller for managing dependency associations.
  class DependenciesController < ApplicationController
    include Paginatable

    before_action :set_source, only: :index
    before_action :set_dependency, only: :destroy

    # GET /[apis|components|resources]/:id/dependencies
    def index
      authorize! @source, to: :show?

      can_destroy = allowed_to?(:update?, @source)
      entities, sort_query = dependencies_query

      render Views::Dependencies::Index.new(
        dependencies: entities,
        pagy: @pagy,
        query: sort_query,
        can_destroy:,
        dependency_map: can_destroy ? dependency_map(entities) : {},
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

    # DELETE /dependencies/:id
    def destroy
      authorize! @dependency.source, to: :update?
      @dependency.destroy!

      redirect_back fallback_location: url_for(@dependency.source),
                    status: :see_other,
                    success: "Dependency was successfully removed."
    end

    private

    # Detects the source entity from nested route params.
    def set_source
      id_key = %i[api_id component_id resource_id].find { |key| params[key].present? }

      @source = case id_key
      when :api_id
        Api.find(params.expect(id_key))
      when :component_id
        Component.find(params.expect(id_key))
      when :resource_id
        Resource.find(params.expect(id_key))
      else
        raise ActiveRecord::RecordNotFound,
          "Couldn't find source for dependencies."
      end
    end

    def set_dependency
      @dependency = Dependency.find(params.expect(:id))
    end

    # Builds and executes a paginated query for dependencies.
    #
    # The API query is used for Ransack sorting and filters.
    #
    # @return [Array(Array<Object>, Ransack::Search)] Entity list and query to
    #   use for sorting.
    def dependencies_query
      api_query = @source.dependent_apis.ransack(params[:q])
      component_query = @source.dependent_components.ransack(params[:q])
      resource_query  = @source.dependent_resources.ransack(params[:q])
      api_query.sorts = "name asc" if api_query.sorts.empty?

      @pagy, entities = paginate(merged_dependency_list(
        api_query,
        [ api_query, component_query, resource_query ]
      ))

      [ entities, api_query ]
    end

    # Builds a map between dependency target entities and their dependency id.
    #
    # @param entities [Array<ApplicationRecord>] Entities to build the map for.
    # @return [Hash<Array<String, Integer>, Integer>] Map of [entity_type,
    #   entity_id] to dependency id.
    def dependency_map(entities)
      @source.dependencies
        .where(
          target_type: entities.map { |e| e.class.name }.uniq,
          target_id: entities.map(&:id)
        )
        .each_with_object({}) do |dep, h|
          key = [ dep.target_type, dep.target_id ]
          h[key] = dep.id
        end
    end

    # Merges results of the different dependency types and sorts them.
    #
    # @param sort_query [Ransack::Search] Query used to determine sorting.
    # @param queries [Array<Ransack::Search>] Queries to merge.
    # @return [Array<Object>] Merged and sorted entity list.
    def merged_dependency_list(sort_query, queries)
      sort = sort_query.sorts.first
      entities = queries.map(&:result).flatten
      sorted = entities.sort_by do |entity|
        [ entity.public_send(sort.name).to_s.downcase, entity.name.to_s.downcase ]
      end

      sort.dir == "desc" ? sorted.reverse : sorted
    end
  end
end
