# frozen_string_literal: true

module Junction
  # Controller for listing dependent entities.
  class DependentsController < ApplicationController
    before_action :set_entity

    include Paginatable

    # GET /[apis|components|resources]/:namespace/:name/dependents
    def index
      authorize! @entity, to: :show?

      entities, sort_query = dependents_query

      render Views::Dependents::Index.new(
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

    def set_entity
      attrs = sanitize_catalog_scope(params)
      unless attrs.key?(:catalog_scope)
        raise ActiveRecord::RecordNotFound, "Couldn't find source for dependents."
      end

      klass = catalog_entity_class(attrs.expect(:catalog_scope))
      raise ActiveRecord::RecordNotFound, "Couldn't find source for dependents." unless klass

      @entity = klass.find_by!(namespace: attrs.expect(:namespace), name: attrs.expect(:name))
    end

    # Builds and executes a paginated query for dependents.
    #
    # @return [Array(ActiveRecord::Relation, Ransack::Search)] Entity list and
    #   query used for sorting.
    def dependents_query
      query = @entity.dependent_sources.ransack(params[:q])
      query.sorts = "name asc" if query.sorts.empty?

      @pagy, entities = paginate(query.result)

      [ entities, query ]
    end
  end
end
