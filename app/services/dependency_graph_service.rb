# frozen_string_literal: true

class DependencyGraphService
  # Initializes the dependency graph service.
  #
  # @param model [ApplicationRecord] The model at the root of the dependency
  #   graph.
  def initialize(model:)
    @model = model

    @dependencies = Set.new
    @entities = {}
    @visited = Set.new
  end

  # Builds the dependency graph.
  #
  # @return [Hash] The dependency graph with all nodes and edges.
  def build
    # Recursive load all dependencies, dependents, and their related entities.
    find_all_related_deps_and_entities(@model)
    load_systems

    {
      nodes:,
      edges:,
      current_node_id: entity_node_id(@model)
    }
  end

  private

  # Recursively find all dependencies, dependents, and entities.
  #
  # @param entity [ApplicationRecord] The current entity to resolve.
  def find_all_related_deps_and_entities(entity)
    return if entity.nil? || @visited.include?(entity)

    @visited << entity
    @entities[entity_node_id(entity)] = entity

    # Find all dependencies where this entity is the source OR the target.
    # We eager-load :source and :target to prevent N+1 queries in the next step.
    deps = Junction::Dependency.where(source: entity)
                     .or(Junction::Dependency.where(target: entity))
                     .includes(:source, :target)
    @dependencies.merge(deps)

    # Resolve dependencies for connected entities.
    find_system_deps_and_entities(entity)
    deps.each do |dep|
      find_all_related_deps_and_entities(dep.source)
      find_all_related_deps_and_entities(dep.target)
    end
  end

  # Find dependencies and entities related to a System entity.
  #
  # While an entity may depend on a system, it can also belong to a system.
  # This method ensures we traverse those relationships as well.
  #
  # @param entity [ApplicationRecord] The system entity to resolve.
  def find_system_deps_and_entities(entity)
    return unless entity.is_a?(System)

    entity.apis.includes(:system).each do |api|
      find_all_related_deps_and_entities(api)
    end

    entity.components.includes(:system).each do |component|
      find_all_related_deps_and_entities(component)
    end

    entity.resources.includes(:system).each do |resource|
      find_all_related_deps_and_entities(resource)
    end
  end

  # Find all systems for the entities we've collected and add them
  def load_systems
    systems_to_load = @entities.values.map do |entity|
      entity.system if entity.respond_to?(:system)
    end.compact.uniq

    systems_to_load.each do |system|
      @entities[entity_node_id(system)] = system
    end
  end

  # Nodes for all the collected entities.
  #
  # @return [Array<Hash>] Array of hashes representing each node.
  def nodes
    @entities.values.map do |entity|
      {
        id: entity_node_id(entity),
        label: entity.name,
        type: entity.class.name.underscore.to_sym
      }
    end
  end

  # Edges for all collected dependencies, dependents, and systems.
  #
  # @return [Array<Hash>] Array of hashes representing each edge.
  def edges
    edges = Set.new
    @dependencies.each do |dep|
      edges << {
        source: entity_node_id(dep.source),
        target: entity_node_id(dep.target)
      }
    end

    # Add edges for systems.
    @entities.values.each do |entity|
      next unless entity.respond_to?(:system) && entity.system

      edges << {
        source: entity_node_id(entity.system),
        target: entity_node_id(entity)
      }
    end

    edges.to_a.uniq
  end

  # Node ID for an entity.
  #
  # @param entity [ApplicationRecord] The entity to generate a node ID for.
  # @return [String] The node ID.
  def entity_node_id(entity)
    "#{entity.class.name.underscore}-#{entity.id}"
  end
end
