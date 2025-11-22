# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    # Base service for GitHub API interactions.
    class ClientService
      DEFAULT_PAGE_SIZE = 10

      # Temporarily enable auto pagination for the duration of the block.
      def paged(&)
        client.auto_paginate = true
        yield
      ensure
        client.auto_paginate = false
      end

      private

      # Client for GitHub API interactions.
      #
      # Auto-pagination is disabled by default to avoid unexpectedly large
      # fetches. See #paged to enable auto-pagination within a block.
      #
      # @return [Octokit::Client] the GitHub API client.
      def client
        @client ||= Octokit::Client.new(auto_paginate: false)
      end
    end
  end
end
