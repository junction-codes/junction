# frozen_string_literal: true

module Junction
  # Controller for managing Domain catalog entities.
  class DomainsController < Junction::ApplicationController
    # Declared before Breadcrumbs so the entity is set before any breadcrumb
    # helper runs.
    include CatalogEntityActions
    load_entity_for :systems

    include Breadcrumbs
    include CatalogOptionSets
    include HasAnnotations
    include HasOwner
    include HasTreeParent
    include Paginatable

    PARENT_CANDIDATE_COLUMNS = %i[description id image_url name namespace title].freeze
    private_constant :PARENT_CANDIDATE_COLUMNS

    # GET /domains/:id/systems
    def systems
      authorize! @entity, to: :show?
      @q = @entity.systems.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, systems = paginate(@q.result)

      render Views::Domains::Systems.new(
        systems:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_systems_domain_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit], q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_systems_domain_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_systems_domain_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /domains/:id
    def show
      authorize! @entity
      render Views::Domains::Show.new(
        domain: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    private

    def entity_class
      Domain
    end

    def index_includes
      %i[parent owner]
    end

    def index_options
      { available_owners:, available_types: }
    end

    def form_options(entity)
      {
        available_owners:,
        available_parents:,
        parent_editable: parent_editable_for?(entity),
        type_options:
      }
    end

    def create_params
      attrs = sanitize_annotations(params.expect(domain: [
        :description, :image_url, :name, :namespace, :owner_id,
        :parent_id, :title, :type, *annotation_param_entries
      ]))

      sanitize_owner_id(
        sanitize_tree_parent_id(attrs, parent_candidates: available_parents)
      )
    end

    # Returns the available parents for the current Domain and user.
    #
    # @return [ActiveRecord::Relation<Domain>] List of parent candidates.
    def available_parents
      parent_candidates_for(
        Domain,
        scope: index_scope_for(Domain),
        columns: PARENT_CANDIDATE_COLUMNS
      )
    end
  end
end
