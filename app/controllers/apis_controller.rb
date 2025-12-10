# frozen_string_literal: true

class ApisController < ApplicationController
  include HasDependencies
  include HasDependencyGraph
  include HasDependents

  before_action :set_entity, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  # GET /api
  def index
    render Views::Apis::Index.new(apis: Api.order(:name))
  end

  # GET /api/:id
  def show
    render Views::Apis::Show.new(api: @entity, dependencies:, dependents:)
  end

  # GET /api/new
  def new
    render Views::Apis::New.new(api: Api.new, owners: owner_options, systems: system_options)
  end

  # GET /api/:id/edit
  def edit
    render Views::Apis::Edit.new(api: @entity, owners: owner_options, systems: system_options)
  end

  # POST /api
  def create
    @entity = Api.new(api_params)

    if @entity.save
      redirect_to @entity, success: "API was successfully created.", status: :see_other
    else
      flash.now[:alert] = "There were errors creating the API."
      render Views::Apis::New.new(api: @entity, owners: owner_options, systems: system_options), status: :unprocessable_entity
    end
  end

  # PATH/PUT /api/:id
  def update
    if @entity.update(api_params)
      redirect_to @entity, success: "API was successfully updated.", status: :see_other
    else
      flash.now[:alert] = "There were errors updating the API."
      render Views::Apis::Edit.new(api: @entity, owners: owner_options, systems: system_options), status: :unprocessable_entity
    end
  end

  # DELETE /api/:id
  def destroy
    @entity.destroy!

    redirect_to apis_path, status: :see_other, alert: "API was successfully destroyed."
  end

  private

  def set_entity
    @entity = Api.find(params.expect(:id))
  end

  def eager_load_dependencies
    @entity = Api.includes(:dependencies, :dependents).find(params.expect(:id))
  end

  def api_params
    params.expect(api: [ :api_type, :name, :description, :definition, :lifecycle, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end

  def owner_options
    Group.order(:name)
  end

  def system_options
    System.order(:name)
  end
end
