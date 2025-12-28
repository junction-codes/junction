class DeploymentsController < ApplicationController
  before_action :set_deployment, only: %i[ show edit update destroy ]

  # GET /deployments or /deployments.json
  def index
    @q = Deployment.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?

    render Views::Deployments::Index.new(
      deployments: @q.result,
      query: @q,
      available_components:,
      available_environments:,
      available_platforms:
    )
  end

  # GET /deployments/1 or /deployments/1.json
  def show
    render Views::Deployments::Show.new(deployment: @deployment)
  end

  # GET /deployments/new
  def new
    render Views::Deployments::New.new(
      deployment: Deployment.new,
      available_components:
    )
  end

  # GET /deployments/1/edit
  def edit
    render Views::Deployments::Edit.new(
      deployment: @deployment,
      available_components:
    )
  end

  # POST /deployments or /deployments.json
  def create
    @deployment = Deployment.new(deployment_params)

    if @deployment.save
      redirect_to @deployment, success: "Deployment was successfully created."
    else
      flash.now[:alert] = "There were errors creating the deployment."
      render Views::Deployments::New.new(deployment: @deployment, available_components:), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deployments/1 or /deployments/1.json
  def update
    if @deployment.update(deployment_params)
      redirect_to @deployment, success: "Deployment was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the deployment."
      render Views::Deployments::Edit.new(deployment: @deployment, available_components:), status: :unprocessable_entity
    end
  end

  # DELETE /deployments/1 or /deployments/1.json
  def destroy
    @deployment.destroy!

    redirect_to deployments_path, status: :see_other, alert: "Deployment was successfully destroyed."
  end

  private

  # Returns a collection of available components for deployments.
  #
  # @return [ActiveRecord::Relation] Collection of components.
  #
  # @todo Only return components that have deployments?
  def available_components
    Component.select(:description, :id, :image_url, :name).order(:name)
  end

  # Returns an array of available environments for deployments.
  #
  # @return [Array<Array(String, String)>] Array of [name, key] pairs for
  #   environments.
  def available_environments
    CatalogOptions.environments.map { |key, opts| [ opts[:name], key ] }
  end

  # Returns an array of available platforms for deployments.
  #
  # @return [Array<Array(String, String)>] Array of [name, key] pairs for
  #   platforms.
  def available_platforms
    CatalogOptions.platforms.map { |key, opts| [ opts[:name], key ] }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_deployment
    @deployment = Deployment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.expect(deployment: [ :environment, :platform, :location_identifier, :component_id ])
  end
end
