# frozen_string_literal: true

module RailJunction
  module Github
    # Displays a list of GitHub pull requests for a given entity.
    #
    # @todo Implement search, filtering, refresh, and pagination.
    class Views::PullRequests::Index < ::Components::Base
      def initialize(entity:, pull_requests:, frame_id:)
        @entity = entity
        @pull_requests = pull_requests
        @frame_id = frame_id
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          div(class: "bg-white dark:bg-gray-800 rounded-xl shadow pb-5") do
            Components::PullRequests::PullRequestsTable(entity: @entity, pull_requests: @pull_requests)
          end
        end
      end
    end
  end
end
