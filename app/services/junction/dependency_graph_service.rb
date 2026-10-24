# frozen_string_literal: true

module Junction
  # Service to build a dependency graph for a given model.
  class DependencyGraphService
    # The edge drawn between a system and what belongs to it.
    #
    # Membership is not a {Relation}, so it has no stored type of its own,
    # but the graph draws it and has to name it like the rest.
    PART_OF = Junction::Relation::PART_OF

    # The relation types the graph draws.
    #
    # A line means one of two things here, and the legend names both: one
    # entity depends on another, or belongs to it. The other types a
    # {Junction::Relation} may carry -- providing and consuming an API --
    # would be drawn as dependencies and read as dependencies, which is not
    # what they say, so they are left out until the design has a line for
    # them. Nothing creates them today: the dependency association is scoped
    # to `depends_on`.
    DRAWN_TYPES = [ Junction::Relation::DEPENDS_ON, PART_OF ].freeze

    # How many steps out from the entity the graph reaches, in each direction.
    #
    # Dependencies are transitive, so an unbounded walk ends up drawing most
    # of a connected catalog for one component, which can fan out into many
    # queries and become unreadable. Two steps is enough to see an entity's
    # neighborhood and makes for a reasonable default.
    DEFAULT_DEPTH = 2

    # Initializes the dependency graph service.
    #
    # @param model [ApplicationRecord] The model at the root of the dependency
    #   graph.
    # @param depth [Integer] How many steps out from the model to walk.
    def initialize(model:, depth: DEFAULT_DEPTH)
      @model = model
      @depth = depth

      @dependencies = Set.new
      @entities = {}
      @visited = Set.new
      @beyond = Set.new
      @aside = Set.new
    end

    # Builds the dependency graph.
    #
    # @return [Hash] The dependency graph with all nodes and edges.
    def build
      walk
      load_systems

      {
        nodes:,
        edges:,
        current_node_id: entity_node_id(@model),
        depth: @depth,
        beyond: (@beyond - @visited).size
      }
    end

    private

    # Walks out from the model, one step at a time, as far as the depth allows.
    #
    # Breadth first rather than depth first, so the entities nearest the model
    # are the ones that fit within the limit. Whatever the last step reached
    # but couldn't follow is counted, so the user knows how much is missing.
    def walk
      frontier = [ @model ]

      (0..@depth).each do |step|
        arrived = frontier.compact.reject { |entity| @visited.include?(entity) }
        break if arrived.empty?

        arrived.each do |entity|
          @visited << entity
          @entities[entity_node_id(entity)] = entity
        end

        next_frontier = neighbors(arrived)

        # Past the limit the frontier is only counted, not drawn.
        @beyond.merge(next_frontier) if step == @depth
        frontier = next_frontier
      end
    end

    # Immediate neighbors one step from an entity, by dependency or membership.
    #
    # @param entity [ApplicationRecord] Starting entity.
    # @return [Array<ApplicationRecord>] The entity's immediate neighbors.
    def neighbors(entities)
      deps = Junction::Relation.where(relation_type: DRAWN_TYPES)
                      .where(source: entities)
                      .or(Junction::Relation.where(relation_type: DRAWN_TYPES)
                                            .where(target: entities))
                      .includes(:source, :target)
      @dependencies.merge(deps)

      deps.flat_map { |dep| [ dep.source, dep.target ] }
    end

    # Find all systems for the entities we've collected and add them
    def load_systems
      members = @entities.values.select { |entity| entity.respond_to?(:system) }

      # Loaded in one query and through the association so that drawing the
      # membership edges reuses it.
      ActiveRecord::Associations::Preloader.new(
        records: members, associations: :system
      ).call

      members.filter_map(&:system).uniq.each do |system|
        id = entity_node_id(system)

        # Marked as context rather than a step in the dependency chain.
        @aside << id unless @entities.key?(id)
        @entities[id] = system
      end
    end

    # Nodes for all the collected entities.
    #
    # The record travels with the node: the graph is drawn as ordinary
    # elements, so the view renders each entity with the same chip and link
    # it has everywhere else rather than from a flattened copy.
    #
    # @return [Array<Hash>] Array of hashes representing each node.
    def nodes
      @entities.values.map do |entity|
        id = entity_node_id(entity)

        { id:, record: entity, aside: @aside.include?(id) }
      end
    end

    # Edges for all collected dependencies, dependents, and systems.
    #
    # A relation reaching past the depth has one end the graph never drew, so
    # it's left out rather than pointing at a node that doesn't exist.
    #
    # @return [Array<Hash>] Array of hashes representing each edge.
    def edges
      edges = Set.new
      @dependencies.each do |dep|
        next unless drawn?(dep.source) && drawn?(dep.target)

        edges << {
          source: entity_node_id(dep.source),
          target: entity_node_id(dep.target),
          type: dep.relation_type
        }
      end

      # Add edges for systems.
      @entities.values.each do |entity|
        next unless entity.respond_to?(:system) && entity.system

        edges << {
          source: entity_node_id(entity.system),
          target: entity_node_id(entity),
          type: PART_OF
        }
      end

      edges.to_a.uniq
    end

    # Whether an entity made it into the graph.
    #
    # @param entity [ApplicationRecord] The entity.
    # @return [Boolean] Whether or not the entity is drawn in the graph.
    def drawn?(entity)
      @entities.key?(entity_node_id(entity))
    end

    # Node ID for an entity.
    #
    # @param entity [ApplicationRecord] The entity to generate a node ID for.
    # @return [String] The node ID.
    def entity_node_id(entity)
      "#{entity.class.name.underscore}-#{entity.id}"
    end
  end
end
