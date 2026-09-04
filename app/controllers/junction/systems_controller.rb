# frozen_string_literal: true

module Junction
  # Controller for managing System catalog entities.
  class SystemsController < ApplicationController
    # Declared before Breadcrumbs so the entity is set before any breadcrumb
    # helper runs.
    include CatalogEntityActions
    load_entity_for :apis, :components, :resources

    include Breadcrumbs
    include CatalogOptionSets
    include HasAnnotations
    include HasOwner
    include Paginatable

    # GET /systems/:id/apis
    def apis
      authorize! @entity, to: :show?
      @q = @entity.apis.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, apis = paginate(@q.result)

      render Views::Systems::Apis.new(
        apis:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_apis_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_apis_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_apis_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /systems/:id/components
    def components
      authorize! @entity, to: :show?
      @q = @entity.components.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, components = paginate(@q.result)

      render Views::Systems::Components.new(
        components:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_components_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_components_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_components_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /systems/:id/resources
    def resources
      authorize! @entity, to: :show?
      @q = @entity.resources.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, resources = paginate(@q.result)

      render Views::Systems::Resources.new(
        resources:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_resources_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_resources_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_resources_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    private

    def entity_class
      System
    end

    def index_options
      { available_domains:, available_owners:, available_types: }
    end

    def form_options(_entity)
      { available_domains:, available_owners:, type_options: }
    end

    def create_params
      sanitize_owner_id(sanitize_annotations(params.expect(system: [
        :description, :domain_id, :name, :namespace, :owner_id,
        :title, :type, *annotation_param_entries
      ])))
    end

    # Returns an array of available domains for systems.
    #
    # @return [Array<Array(String, Integer)>] Array of [name, id] pairs for
    #   domains.
    def available_domains
      Domain.select(:description, :id, :image_url, :title).order(:title)
    end
  end
end
