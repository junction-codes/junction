# frozen_string_literal: true

module RailJunction
  module Github
    class PullRequestsController < ApplicationController
      before_action :set_component

      def index
        render RailJunction::Github::Views::PullRequests::Index.new(
          entity: @component,
          pull_requests: RepositoryService.new(slug:).pull_requests,
          frame_id: "component_github_pull_requests",
        )
      end

      private

      def set_component
        @component = @entity = ::Component.find(params[:component_id])
      end
    end
  end
end
