# frozen_string_literal: true

module RailJunction
  module Github
    class PullRequestsController < ApplicationController
      before_action :set_entity

      def index
        render RailJunction::Github::Views::PullRequests::Index.new(
          entity: @entity,
          pull_requests:,
          frame_id: frame_id("github-pull-requests")
        )
      end

      private

      def pull_requests
        service = context == Group ? TeamService : RepositoryService
        service.new(slug:).pull_requests
      end
    end
  end
end
