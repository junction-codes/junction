class DeploymentsController < ApplicationController
  before_action :set_deployment, only: %i[ show edit update destroy ]

  # GET /deployments or /deployments.json
  def index
    render Views::Deployments::Index.new(
      deployments: Deployment.order(:created_at),
    )
  end

  # GET /deployments/1 or /deployments/1.json
  def show
    render Views::Deployments::Show.new(
      deployment: @deployment
    )
  end

  # GET /deployments/new
  def new
    render Views::Deployments::New.new(
      deployment: Deployment.new
    )
  end

  # GET /deployments/1/edit
  def edit
    render Views::Deployments::Edit.new(
      deployment: @deployment
    )
  end

  # POST /deployments or /deployments.json
  def create
    @deployment = Deployment.new(deployment_params)

    if @deployment.save
      redirect_to @deployment, success: "Deployment was successfully created."
    else
      flash.now[:alert] = "There were errors creating the deployment."
      render Views::Deployments::New.new(deployment: @deployment), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deployments/1 or /deployments/1.json
  def update
    if @deployment.update(deployment_params)
      redirect_to @deployment, success: "Deployment was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the deployment."
      render Views::Deployments::Edit.new(deployment: @deployment), status: :unprocessable_entity
    end
  end

  # DELETE /deployments/1 or /deployments/1.json
  def destroy
    @deployment.destroy!

    redirect_to deployments_path, status: :see_other, alert: "Deployment was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_deployment
    @deployment = Deployment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.expect(deployment: [ :environment, :platform, :location_identifier, :component_id ])
  end
end
