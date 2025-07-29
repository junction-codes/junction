class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

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
      render Views::Projects::New.new(project: @project), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:id
  def update
    if @project.update(project_params)
      redirect_to @project, success: "Project was successfully updated."
    else
      render Views::Projects::Edit.new(project: @project), status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  def destroy
    @project.destroy!

    redirect_to projects_path, status: :see_other, destructive: "Project was successfully destroyed."
  end

  private

  def set_project
    @project = Project.find(params.expect(:id))
  end

  def project_params
    params.expect(project: [ :name, :description, :status, :program_id ])
  end
end
