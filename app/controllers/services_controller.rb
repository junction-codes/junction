class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy ]

  # GET /services
  def index
    render Views::Services::Index.new(
      services: Service.order(:name),
    )
  end

  # GET /services/:id
  def show
    render Views::Services::Show.new(
      service: @service,
    )
  end

  # GET /services/new
  def new
    render Views::Services::New.new(
      service: Service.new,
    )
  end

  # GET /services/:id/edit
  def edit
    render Views::Services::Edit.new(
      service: @service,
    )
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    if @service.save
      redirect_to @service, success: "Service was successfully created."
    else
      flash.now[:alert] = "There were errors creating the service."
      render Views::Services::New.new(service: @service), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /services/:id
  def update
    if @service.update(service_params)
      redirect_to @service, success: "Service was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the service."
      render Views::Services::Edit.new(service: @service), status: :unprocessable_entity
    end
  end

  # DELETE /services/:id
  def destroy
    @service.destroy!

    redirect_to projects_path, status: :see_other, alert: "Service was successfully destroyed."
  end

  private

  def set_service
    @service = Service.find(params.expect(:id))
  end

  def service_params
    params.expect(service: [ :name, :description, :status, :program_id, :image_url ])
  end
end
