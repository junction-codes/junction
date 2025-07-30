class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy dependency_graph ]

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

    redirect_to services_path, status: :see_other, alert: "Service was successfully destroyed."
  end

  # GET /projects/:id/dependency_graph
  #
  # @todo Break this up into smaller methods for better readability.
  def dependency_graph
    # Start with our service, it's dependencies, dependents, and their
    # associated projects.
    all_related_services = ([@service] + @service.dependencies + @service.dependents).uniq
    projects = Project.joins(:services).where(services: { id: all_related_services.map(&:id) }).distinct

    nodes = all_related_services.map do |s|
      { id: s.id, label: s.name, type: :service }
    end

    nodes += projects.map do |p|
      { id: "project_#{p.id}", label: p.name, type: :project }
    end

    # Create edges for service-to-service dependencies.
    edges = []
    @service.dependencies.each { |dep| edges << { source: @service.id, target: dep.id } }
    @service.dependents.each { |dep| edges << { source: dep.id, target: @service.id } }

    # Create edges from services to their associated projects.
    all_related_services.each do |s|
      s.project_ids.each do |project_id|
        edges << { target: s.id, source: "project_#{project_id}" }
      end
    end

    render json: { nodes: nodes, edges: edges, current_node_id: @service.id }
  end

  private

  def set_service
    @service = Service.find(params.expect(:id))
  end

  def service_params
    params.expect(service: [ :name, :description, :status, :program_id, :image_url ])
  end
end
