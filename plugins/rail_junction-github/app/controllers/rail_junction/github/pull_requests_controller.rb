# frozen_string_literal: true

module RailJunction
  module Github
    class PullRequestsController < ApplicationController
      before_action :set_component

      def index
        render RailJunction::Github::Views::PullRequests::Index.new(
          object: @component,
          pull_requests: client.pull_requests,
          frame_id: "component_github_pull_requests",
        )
      end

      private

      def set_component
        @component = @object = ::Component.find(params[:component_id])
      end
    end
  end
end
