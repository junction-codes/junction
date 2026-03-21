# frozen_string_literal: true

module Junction
  # Controller for managing Resource catalog entities.
  class ResourcesController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

    include Breadcrumbs
    include HasDependencies
    include HasDependencyGraph
    include HasDependents
    include HasOwner
    include Paginatable

    # GET /resources
    def index
      authorize! Resource
      @q = index_scope_for(Resource).ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, resources = paginate(@q.result)

      render Views::Resources::Index.new(
        resources:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Resource),
        available_owners:,
        available_systems:,
        available_types:,
      )
    end

    # GET /resources/:id
    def show
      authorize! @entity
      render Views::Resources::Show.new(
        resource: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        dependencies:,
        dependents:
      )
    end

    # GET /resources/new
    def new
      authorize! Resource
      render Views::Resources::New.new(
        resource: Resource.new,
        breadcrumbs:,
        available_owners:,
        available_systems:
      )
    end

    # GET /resources/:id/edit
    def edit
      authorize! @entity
      render Views::Resources::Edit.new(
        resource: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_systems:
      )
    end

    # POST /resources
    def create
      authorize! Resource
      @entity = Resource.new(resource_params)

      if @entity.save
        redirect_to @entity, success: "Resource was successfully created."
      else
        flash.now[:alert] = "There were errors creating the resource."
        render Views::Resources::New.new(resource: @entity, breadcrumbs:, available_owners:, available_systems:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /resources/:id
    def update
      authorize! @entity
      if @entity.update(resource_params)
        redirect_to @entity, success: "Resource was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the resource."
        render Views::Resources::Edit.new(
          resource: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_owners:,
          available_systems:
        ), status: :unprocessable_content
      end
    end

    # DELETE /resources/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to resources_path, status: :see_other, success: "Resource was successfully destroyed."
    end

    private

    # Returns a collection of available systems for resources.
    #
    # @return [ActiveRecord::Relation] Collection of systems.
    def available_systems
      System.select(:description, :id, :image_url, :name).order(:name)
    end

    # Returns an array of available types for resources.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for types.
    def available_types
      CatalogOptions.resources.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Resource.find(params.expect(:id))
    end

    def eager_load_dependencies
      @entity = Resource.includes(:dependencies, :dependents)
                        .find(params.expect(:id))
    end

    def resource_params
      sanitize_owner_id(params.expect(resource: [
        :name, :description, :type, :image_url, :owner_id, :resource_type,
        :system_id, annotations: {}
      ]))
    end
  end
end
