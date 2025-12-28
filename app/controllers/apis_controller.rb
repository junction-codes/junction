# frozen_string_literal: true

class ApisController < ApplicationController
  include HasDependencies
  include HasDependencyGraph
  include HasDependents

  before_action :set_entity, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  # GET /api
  def index
    @q = Api.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?

    render Views::Apis::Index.new(
      apis: @q.result,
      query: @q,
      available_lifecycles:,
      available_owners:,
      available_systems:,
      available_types:,
    )
  end

  # GET /api/:id
  def show
    render Views::Apis::Show.new(api: @entity, dependencies:, dependents:)
  end

  # GET /api/new
  def new
    render Views::Apis::New.new(api: Api.new, available_owners:, available_systems:)
  end

  # GET /api/:id/edit
  def edit
    render Views::Apis::Edit.new(api: @entity, available_owners:, available_systems:)
  end

  # POST /api
  def create
    @entity = Api.new(api_params)

    if @entity.save
      redirect_to @entity, success: "API was successfully created.", status: :see_other
    else
      flash.now[:alert] = "There were errors creating the API."
      render Views::Apis::New.new(api: @entity, available_owners:, available_systems:), status: :unprocessable_entity
    end
  end

  # PATH/PUT /api/:id
  def update
    if @entity.update(api_params)
      redirect_to @entity, success: "API was successfully updated.", status: :see_other
    else
      flash.now[:alert] = "There were errors updating the API."
      render Views::Apis::Edit.new(api: @entity, available_owners:, available_systems:), status: :unprocessable_entity
    end
  end

  # DELETE /api/:id
  def destroy
    @entity.destroy!

    redirect_to apis_path, status: :see_other, alert: "API was successfully destroyed."
  end

  private

  # Returns an array of available lifecycles for apis.
  #
  # @return [Array<Array(String, String)>] Array of [name, key] pairs for
  #   lifecycles.
  def available_lifecycles
    CatalogOptions.lifecycles.map { |key, opts| [ opts[:name], key ] }
  end

  # Returns an array of available owners for apis.
  #
  # @return [Array<Array(String, Integer)>] Array of [name, id] pairs for
  #   owners.
  def available_owners
    Group.select(:description, :id, :image_url, :name).order(:name)
  end

  # Returns an array of available systems for apis.
  #
  # @return [Array<Array(String, Integer)>] Array of [name, id] pairs for
  #   systems.
  def available_systems
    System.select(:description, :id, :image_url, :name).order(:name)
  end

  # Returns an array of available types for apis.
  #
  # @return [Array<Array(String, String)>] Array of [name, key] pairs for
  #   types.
  def available_types
    CatalogOptions.apis.map { |key, opts| [ opts[:name], key ] }
  end

  def set_entity
    @entity = Api.find(params.expect(:id))
  end

  def eager_load_dependencies
    @entity = Api.includes(:dependencies, :dependents).find(params.expect(:id))
  end

  def api_params
    params.expect(api: [ :api_type, :name, :description, :definition, :lifecycle, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end
end
