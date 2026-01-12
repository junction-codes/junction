# frozen_string_literal: true

# Controller for managing Resource catalog entities.
module Junction
  class ResourcesController < Junction::ApplicationController
  include HasDependencies
  include HasDependencyGraph
  include HasDependents

  before_action :set_entity, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  # GET /resources
  def index
    @q = Resource.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?

    render Views::Resources::Index.new(
      resources: @q.result,
      query: @q,
      available_owners:,
      available_systems:,
      available_types:,
    )
  end

  # GET /resources/:id
  def show
    render Views::Resources::Show.new(resource: @entity, dependencies:, dependents:)
  end

  # GET /resources/new
  def new
    render Views::Resources::New.new(
      resource: Resource.new,
      available_owners:,
      available_systems:
    )
  end

  # GET /resources/:id/edit
  def edit
    render Views::Resources::Edit.new(
      resource: @entity,
      available_owners:,
      available_systems:
    )
  end

  # POST /resources
  def create
    @entity = Resource.new(resource_params)

    if @entity.save
      redirect_to @entity, success: "Resource was successfully created."
    else
      flash.now[:alert] = "There were errors creating the resource."
      render Views::Resources::New.new(resource: @entity, available_owners:, available_systems:), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /resources/:id
  def update
    if @entity.update(resource_params)
      redirect_to @entity, success: "Resource was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the resource."
      render Views::Resources::Edit.new(resource: @entity, available_owners:, available_systems:), status: :unprocessable_entity
    end
  end

  # DELETE /resources/:id
  def destroy
    @entity.destroy!

    redirect_to resources_path, status: :see_other, alert: "Resource was successfully destroyed."
  end

  private

  # Returns a collection of available owners for resources.
  #
  # @return [ActiveRecord::Relation] Collection of owners.
  def available_owners
    Group.select(:description, :id, :image_url, :name).order(:name)
  end

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
    params.expect(resource: [ :name, :description, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end
end
end
