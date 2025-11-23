# frozen_string_literal: true

module HasDependencyGraph
  extend ActiveSupport::Concern

  # GET /:entity/:id/dependency_graph
  def dependency_graph
    graph_data = DependencyGraphService.new(model: @entity).build
    render json: graph_data
  end
end
