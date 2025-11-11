class ComponentsController < ApplicationController
  before_action :set_component, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  # GET /components
  def index
    render Views::Components::Index.new(
      components: Component.order(:name),
    )
  end

  # GET /components/:id
  def show
    render Views::Components::Show.new(
      component: @component,
      dependencies: (@component.dependent_components + @component.dependent_resources).sort_by(&:name),
      dependents: (@component.component_dependents + @component.resource_dependents).sort_by(&:name)
    )
  end

  # GET /components/new
  def new
    render Views::Components::New.new(
      component: Component.new,
      owners: Group.order(:name)
    )
  end

  # GET /components/:id/edit
  def edit
    render Views::Components::Edit.new(
      component: @component,
      owners: Group.order(:name)
    )
  end

  # POST /components
  def create
    @component = Component.new(component_params)

    if @component.save
      redirect_to @component, success: "Component was successfully created."
    else
      flash.now[:alert] = "There were errors creating the component."
      render Views::Components::New.new(component: @component, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /components/:id
  def update
    if @component.update(component_params)
      redirect_to @component, success: "Component was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the component."
      render Views::Components::Edit.new(component: @component, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # DELETE /components/:id
  def destroy
    @component.destroy!

    redirect_to components_path, status: :see_other, alert: "Component was successfully destroyed."
  end

  # GET /components/:id/dependency_graph
  def dependency_graph
    graph_data = DependencyGraphService.new(model: @component).build
    render json: graph_data
  end

  private

  def set_component
    @component = Component.find(params.expect(:id))
  end

  def eager_load_dependencies
    @component = Component.includes(:dependencies, :dependents)
                        .find(params.expect(:id))
  end

  def component_params
    params.expect(component: [ :name, :description, :repository_url, :lifecycle, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end
end
