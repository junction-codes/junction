# frozen_string_literal: true

module Junction
  module HasDependencyGraph
    extend ActiveSupport::Concern

    # GET /:entity/:id/dependency_graph
    def dependency_graph
      authorize! @entity, to: :show?

      render Views::Entities::DependencyGraph.new(
        entity: @entity,
        graph: DependencyGraphService.new(model: @entity).build
      )
    end
  end
end
