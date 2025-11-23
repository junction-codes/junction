# frozen_string_literal: true

module RailJunction
  module Github
    class ActionsController < ApplicationController
      before_action :set_entity

      def index
        render RailJunction::Github::Views::Actions::Index.new(
          entity: @entity,
          workflow_runs: RepositoryService.new(slug:).workflow_runs,
          frame_id: frame_id("github-actions"),
        )
      end
    end
  end
end
