class ResourcesController < ApplicationController
  before_action :set_resource, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  def index
    render Views::Resources::Index.new(
      resources: Resource.order(:name),
    )
  end

  def show
    render Views::Resources::Show.new(
      resource: @resource,
      dependencies: (@resource.dependent_components + @resource.dependent_resources).sort_by(&:name),
      dependents: (@resource.component_dependents + @resource.resource_dependents).sort_by(&:name)
    )
  end

  def new
    render Views::Resources::New.new(
      resource: Resource.new,
      owners: Group.order(:name)
    )
  end

  def edit
    render Views::Resources::Edit.new(
      resource: @resource,
      owners: Group.order(:name)
    )
  end

  def create
    @resource = Resource.new(resource_params)

    if @resource.save
      redirect_to @resource, success: "Resource was successfully created."
    else
      flash.now[:alert] = "There were errors creating the resource."
      render Views::Resources::New.new(resource: @resource, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  def update
    if @resource.update(resource_params)
      redirect_to @resource, success: "Resource was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the resource."
      render Views::Resources::Edit.new(resource: @resource, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy!

    redirect_to resources_path, status: :see_other, alert: "Resource was successfully destroyed."
  end

  # GET /resources/:id/dependency_graph
  def dependency_graph
    graph_data = DependencyGraphService.new(model: @resource).build
    render json: graph_data
  end

  private

  def set_resource
    @resource = Resource.find(params.expect(:id))
  end

  def eager_load_dependencies
    @resource = Resource.includes(:dependencies, :dependents)
                        .find(params.expect(:id))
  end

  def resource_params
    params.expect(resource: [ :name, :description, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end
end
