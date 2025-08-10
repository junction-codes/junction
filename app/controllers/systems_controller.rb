class SystemsController < ApplicationController
  before_action :set_system, only: %i[ show edit update destroy dependency_graph ]

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
    )
  end

  # GET /systems/:id/edit
  def edit
    render Views::Systems::Edit.new(
      system: @system,
    )
  end

  # POST /systems
  def create
    @system = System.new(system_params)

    if @system.save
      redirect_to @system, success: "System was successfully created."
    else
      flash.now[:alert] = "There were errors creating the system."
      render Views::Systems::New.new(system: @system), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /systems/:id
  def update
    if @system.update(system_params)
      redirect_to @system, success: "System was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the system."
      render Views::Systems::Edit.new(system: @system), status: :unprocessable_entity
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
    all_components = Set.new
    all_edges = Set.new

    # Starting with the dependencies of the current component, traverse the tree
    # of components to find all dependencies.
    components_to_process = @system.components.to_a
    component_to_check = components_to_process.shift
    while component_to_check
      if all_components.include?(component_to_check)
        component_to_check = components_to_process.shift
        next
      end

      all_components.add(component_to_check)

      # Find dependencies of the current component and add them to the set to be
      # processed, but only if we haven't encountered them before.
      component_to_check.dependencies.each do |dependency|
        all_edges.add([component_to_check.id, dependency.id])
        components_to_process.push(dependency) unless all_components.include?(dependency)
      end

      component_to_check = components_to_process.shift
    end

    # Find all the systems that depend on the discovered components.
    all_system_ids = SystemComponent.where(component_id: all_components.map(&:id))
                                    .pluck(:system_id).uniq
    all_systems = System.find(all_system_ids)

    nodes = all_components.map do |component|
      { id: component.id, label: component.name, type: :component }
    end

    nodes += all_systems.map do |p|
      { id: "system_#{p.id}", label: p.name, type: :system }
    end

    # Build edges for component-to-component dependencies.
    edges = all_edges.map do |source_id, target_id|
      { source: source_id, target: target_id }
    end

    # Add edges from components to their dependent systems.
    component_to_system_links = SystemComponent.where(component_id: all_components.map(&:id))
                                             .pluck(:component_id, :system_id)
    component_to_system_links.each do |component_id, system_id|
      edges << { target: component_id, source: "system_#{system_id}" }
    end

    render json: {
      nodes: nodes.uniq,
      edges: edges.uniq,
      current_node_id: "system_#{@system.id}"
    }
  end

  private

  def set_system
    @system = System.find(params.expect(:id))
  end

  def system_params
    params.expect(system: [ :name, :description, :status, :domain_id ])
  end
end
