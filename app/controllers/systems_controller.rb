class SystemsController < ApplicationController
  before_action :set_entity, only: %i[ show edit update destroy dependency_graph ]

  # GET /systems
  def index
    render Views::Systems::Index.new(
      systems: System.order(:name),
    )
  end

  # GET /systems/:id
  def show
    render Views::Systems::Show.new(
      system: @system,
    )
  end

  # GET /systems/new
  def new
    render Views::Systems::New.new(
      system: System.new,
      owners: Group.order(:name)
    )
  end

  # GET /systems/:id/edit
  def edit
    render Views::Systems::Edit.new(
      system: @system,
      owners: Group.order(:name)
    )
  end

  # POST /systems
  def create
    @system = System.new(system_params)

    if @system.save
      redirect_to @system, success: "System was successfully created."
    else
      flash.now[:alert] = "There were errors creating the system."
      render Views::Systems::New.new(system: @system, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /systems/:id
  def update
    if @system.update(system_params)
      redirect_to @system, success: "System was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the system."
      render Views::Systems::Edit.new(system: @system, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # DELETE /systems/:id
  def destroy
    @system.destroy!

    redirect_to systems_path, status: :see_other, alert: "System was successfully destroyed."
  end

  # GET /systems/:id/dependency_graph
  #
  # @todo Break this up into smaller methods for better readability.
  def dependency_graph
    graph_data = DependencyGraphService.new(model: @system).build
    render json: graph_data
  end

  private

  def set_entity
    @system = System.find(params.expect(:id))
  end

  def system_params
    params.expect(system: [ :name, :description, :status, :domain_id, :owner_id ])
  end
end
