# frozen_string_literal: true

module Junction
  # Controller for managing Resource catalog entities.
  class ResourcesController < Junction::ApplicationController
    include Junction::HasDependencies
    include Junction::HasDependencyGraph
    include Junction::HasDependents
    include Junction::HasOwner

    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

    # GET /resources
    def index
      authorize! Junction::Resource
      @q = index_scope_for(Junction::Resource).ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Resources::Index.new(
        resources: @q.result,
        query: @q,
        can_create: allowed_to?(:create?, Junction::Resource),
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
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        dependencies:,
        dependents:
      )
    end

    # GET /resources/new
    def new
      authorize! Junction::Resource
      render Views::Resources::New.new(
        resource: Junction::Resource.new,
        available_owners:,
        available_systems:
      )
    end

    # GET /resources/:id/edit
    def edit
      authorize! @entity
      render Views::Resources::Edit.new(
        resource: @entity,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_systems:
      )
    end

    # POST /resources
    def create
      authorize! Junction::Resource
      @entity = Junction::Resource.new(resource_params)

      if @entity.save
        redirect_to @entity, success: "Resource was successfully created."
      else
        flash.now[:alert] = "There were errors creating the resource."
        render Views::Resources::New.new(resource: @entity, available_owners:, available_systems:),
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

      redirect_to resources_path, status: :see_other, alert: "Resource was successfully destroyed."
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
      Junction::CatalogOptions.resources.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Junction::Resource.find(params.expect(:id))
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
