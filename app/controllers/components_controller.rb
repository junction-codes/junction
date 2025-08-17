class ComponentsController < ApplicationController
  before_action :set_component, only: %i[ show edit update destroy dependency_graph ]

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

  # GET /systems/:id/dependency_graph
  #
  # @todo Break this up into smaller methods for better readability.
  def dependency_graph
    # Start with our component, it's dependencies, dependents, and their
    # associated systems.
    all_related_components = ([ @component ] + @component.dependencies + @component.dependents).uniq
    systems = System.joins(:components).where(components: { id: all_related_components.map(&:id) }).distinct

    nodes = all_related_components.map do |s|
      { id: s.id, label: s.name, type: :component }
    end

    nodes += systems.map do |p|
      { id: "system_#{p.id}", label: p.name, type: :system }
    end

    # Create edges for component-to-component dependencies.
    edges = []
    @component.dependencies.each { |dep| edges << { source: @component.id, target: dep.id } }
    @component.dependents.each { |dep| edges << { source: dep.id, target: @component.id } }

    # Create edges from components to their associated systems.
    all_related_components.each do |s|
      s.system_ids.each do |system_id|
        edges << { target: s.id, source: "system_#{system_id}" }
      end
    end

    render json: { nodes: nodes, edges: edges, current_node_id: @component.id }
  end

  private

  def set_component
    @component = Component.find(params.expect(:id))
  end

  def component_params
    params.expect(component: [ :name, :description, :repository_url, :lifecycle, :type, :domain_id, :image_url, :owner_id ])
  end
end
