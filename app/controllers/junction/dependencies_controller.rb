# frozen_string_literal: true

module Junction
  # Controller for managing dependency associations.
  class DependenciesController < ApplicationController
    include ReadScoped
    include Paginatable

    before_action :set_source, only: %i[index create search]
    before_action :set_dependency, only: :destroy

    # GET /[apis|components|resources]/:namespace/:name/dependencies
    def index
      authorize! @source, to: :show?

      can_edit = allowed_to?(:update?, @source)
      entities, sort_query = dependencies_query

      render Views::Dependencies::Index.new(
        dependencies: entities,
        pagy: @pagy,
        query: sort_query,
        can_destroy: can_edit,
        dependency_map: can_edit ? dependency_map(entities) : {},
        can_create: can_edit,
        create_url: can_edit ? junction_dependencies_path(@source) : nil,
        search_url: can_edit ? junction_search_dependencies_path(@source) : nil,
        page_url: ->(page) {
          junction_dependencies_path(
            @source,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_dependencies_path(@source, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_dependencies_path(
            @source,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # POST /[apis|components|resources]/:namespace/:name/dependencies
    def create
      authorize! @source, to: :update?

      @dependency = @source.dependencies.build(target_id: decode_entity(dependency_params[:target]))

      if @dependency.save
        redirect_back fallback_location: junction_catalog_path(@source),
                      status: :see_other,
                      success: "Dependency was successfully added."
      else
        redirect_back fallback_location: junction_catalog_path(@source),
                      status: :see_other,
                      alert: @dependency.errors.full_messages.to_sentence
      end
    end

    # GET /[apis|components|resources]/:namespace/:name/dependencies/search
    def search
      authorize! @source, to: :show?

      q = params[:q].to_s.strip

      excluded = @source.dependencies.pluck(:target_id) +
                 @source.dependents.pluck(:source_id) + [ @source.id ]

      results = viewable_scope
        .where(kind: Junction::Kinds.dependable_names)
        .where("title ILIKE ?", "%#{q}%")
        .where.not(id: excluded)
        .order(:title)
        .limit(10)

      render Views::Dependencies::Search.new(results:)
    end

    # DELETE /dependencies/:id
    def destroy
      authorize! @dependency.source, to: :update?
      @dependency.destroy!

      redirect_back fallback_location: junction_catalog_path(@dependency.source),
                    status: :see_other,
                    success: "Dependency was successfully removed."
    end

    private

    # Scope of entities the user may view and depend on.
    #
    # @return [ActiveRecord::Relation] Scope restricted to entities the user is
    #   permitted to view.
    def viewable_scope
      entity_scope_for(Junction::Kinds.all.select(&:dependable?))
    end

    # Expected parameters for a dependency.
    #
    # @return [Hash] The expected parameters.
    def dependency_params
      params.expect(dependency: [ :target ])
    end

    # Extracts the entity id from a submitted target value.
    #
    # Targets used to be encoded as "Junction::Api:12" because the id alone
    # was ambiguous across tables. One table means the id is enough, but the
    # older form is still accepted.
    #
    # @param value [String] The submitted value.
    # @return [Integer, nil] The entity id.
    def decode_entity(value)
      return nil if value.blank?

      value.to_s.split(":").last.to_i
    end

    # Detects the source entity from nested route params.
    def set_source
      attrs = sanitize_catalog_scope(params)
      unless attrs.key?(:catalog_scope)
        raise ActiveRecord::RecordNotFound, "Couldn't find source for dependencies."
      end

      klass = catalog_entity_class(attrs.expect(:catalog_scope))
      raise ActiveRecord::RecordNotFound, "Couldn't find source for dependencies." unless klass

      @source = klass.find_by!(namespace: attrs.expect(:namespace), name: attrs.expect(:name))
    end

    def set_dependency
      @dependency = Relation.find(params.expect(:id))
    end

    # Builds and executes a paginated query for dependencies.
    #
    # The API query is used for Ransack sorting and filters.
    #
    # @return [Array(Array<Object>, Ransack::Search)] Entity list and query to
    #   use for sorting.
    def dependencies_query
      query = @source.dependency_targets.ransack(params[:q])
      query.sorts = "title asc" if query.sorts.empty?

      @pagy, entities = paginate(query.result)

      [ entities, query ]
    end

    # Builds a map between dependency target entities and their relation id.
    #
    # @param entities [Array<Junction::Entity>] Entities to build the map for.
    # @return [Hash<Integer, Integer>] Map of entity id to relation id.
    def dependency_map(entities)
      @source.dependencies
        .where(target_id: entities.map(&:id))
        .pluck(:target_id, :id)
        .to_h
    end
  end
end
