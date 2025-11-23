class ComponentsController < ApplicationController
  include HasDependencies
  include HasDependencyGraph
  include HasDependents

  before_action :set_entity, only: %i[ edit update destroy ]
  before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

  # GET /components
  def index
    render Views::Components::Index.new(
      components: Component.order(:name),
    )
  end

  # GET /components/:id
  def show
    render Views::Components::Show.new(component: @entity, dependencies:, dependents:)
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
      component: @entity,
      owners: Group.order(:name)
    )
  end

  # POST /components
  def create
    @entity = Component.new(component_params)

    if @entity.save
      redirect_to @entity, success: "Component was successfully created."
    else
      flash.now[:alert] = "There were errors creating the component."
      render Views::Components::New.new(component: @entity, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /components/:id
  def update
    if @entity.update(component_params)
      redirect_to @entity, success: "Component was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the component."
      render Views::Components::Edit.new(component: @entity, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # DELETE /components/:id
  def destroy
    @entity.destroy!

    redirect_to components_path, status: :see_other, alert: "Component was successfully destroyed."
  end

  private

  def set_entity
    @entity = Component.find(params.expect(:id))
  end

  def eager_load_dependencies
    @entity = Component.includes(:dependencies, :dependents)
                        .find(params.expect(:id))
  end

  def component_params
    params.expect(component: [ :name, :description, :repository_url, :lifecycle, :type, :image_url, :owner_id, :system_id, annotations: {} ])
  end
end
