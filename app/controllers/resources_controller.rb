# frozen_string_literal: true

class ResourcesController < ApplicationController
  include HasDependencies
  include HasDependencyGraph
  include HasDependents

  before_action :set_resource, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  def index
    render Views::Resources::Index.new(
      resources: Resource.order(:name),
    )
  end

  def show
    render Views::Resources::Show.new(resource: @entity, dependencies:, dependents:)
  end

  def new
    render Views::Resources::New.new(
      resource: Resource.new,
      owners: Group.order(:name)
    )
  end

  def edit
    render Views::Resources::Edit.new(
      resource: @entity,
      owners: Group.order(:name)
    )
  end

  def create
    @entity = Resource.new(resource_params)

    if @entity.save
      redirect_to @entity, success: "Resource was successfully created."
    else
      flash.now[:alert] = "There were errors creating the resource."
      render Views::Resources::New.new(resource: @entity, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  def update
    if @entity.update(resource_params)
      redirect_to @entity, success: "Resource was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the resource."
      render Views::Resources::Edit.new(resource: @entity, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  def destroy
    @entity.destroy!

    redirect_to resources_path, status: :see_other, alert: "Resource was successfully destroyed."
  end

  private

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
