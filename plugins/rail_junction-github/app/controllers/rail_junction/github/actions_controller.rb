# frozen_string_literal: true

module RailJunction
  module Github
    class ActionsController < ApplicationController
      before_action :set_component

      def index
        render RailJunction::Github::Views::Actions::Index.new(
          entity: @component,
          workflow_runs: RepositoryService.new(slug:).workflow_runs,
          frame_id: "component_github_actions",
        )
      end

      private

      def set_component
        @component = @entity = ::Component.find(params[:component_id])
      end
    end
  end
end
