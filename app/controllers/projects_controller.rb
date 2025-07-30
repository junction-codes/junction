class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy dependency_graph ]

  # GET /projects
  def index
    render Views::Projects::Index.new(
      projects: Project.order(:name),
    )
  end

  # GET /projects/:id
  def show
    render Views::Projects::Show.new(
      project: @project,
    )
  end

  # GET /projects/new
  def new
    render Views::Projects::New.new(
      project: Project.new,
    )
  end

  # GET /projects/:id/edit
  def edit
    render Views::Projects::Edit.new(
      project: @project,
    )
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, success: "Project was successfully created."
    else
      flash.now[:alert] = "There were errors creating the project."
      render Views::Projects::New.new(project: @project), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:id
  def update
    if @project.update(project_params)
      redirect_to @project, success: "Project was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the project."
      render Views::Projects::Edit.new(project: @project), status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  def destroy
    @project.destroy!

    redirect_to projects_path, status: :see_other, alert: "Project was successfully destroyed."
  end

  # GET /projects/:id/dependency_graph
  #
  # @todo Break this up into smaller methods for better readability.
  def dependency_graph
    all_services = Set.new
    all_edges = Set.new

    # Starting with the dependencies of the current service, traverse the tree
    # of services to find all dependencies.
    services_to_process = @project.services.to_a
    service_to_check = services_to_process.shift
    while service_to_check
      if all_services.include?(service_to_check)
        service_to_check = services_to_process.shift
        next
      end

      all_services.add(service_to_check)

      # Find dependencies of the current service and add them to the set to be
      # processed, but only if we haven't encountered them before.
      service_to_check.dependencies.each do |dependency|
        all_edges.add([service_to_check.id, dependency.id])
        services_to_process.push(dependency) unless all_services.include?(dependency)
      end

      service_to_check = services_to_process.shift
    end

    # Find all the projects that depend on the discovered services.
    all_project_ids = ProjectService.where(service_id: all_services.map(&:id))
                                    .pluck(:project_id).uniq
    all_projects = Project.find(all_project_ids)

    nodes = all_services.map do |service|
      { id: service.id, label: service.name, type: :service }
    end

    nodes += all_projects.map do |p|
      { id: "project_#{p.id}", label: p.name, type: :project }
    end

    # Build edges for service-to-service dependencies.
    edges = all_edges.map do |source_id, target_id|
      { source: source_id, target: target_id }
    end

    # Add edges from services to their dependent projects.
    service_to_project_links = ProjectService.where(service_id: all_services.map(&:id))
                                             .pluck(:service_id, :project_id)
    service_to_project_links.each do |service_id, project_id|
      edges << { target: service_id, source: "project_#{project_id}" }
    end

    render json: {
      nodes: nodes.uniq,
      edges: edges.uniq,
      current_node_id: "project_#{@project.id}"
    }
  end

  private

  def set_project
    @project = Project.find(params.expect(:id))
  end

  def project_params
    params.expect(project: [ :name, :description, :status, :program_id ])
  end
end
