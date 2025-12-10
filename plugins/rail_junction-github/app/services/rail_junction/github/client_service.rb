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

      # Execute a GraphQL query with optional variables.
      #
      # @param query [String] the GraphQL query string.
      # @param variables [Hash] Optional variables for the query.
      # @return [Array<Hash>] Aggregated results from the query.
      def graphql(query:, variables: {})
        results = []
        loop do
          resp = client.post "/graphql", { query: query, variables: variables }.to_json
          pp(resp)
          results.concat(resp.dig(:data, :search, :nodes) || [])

          page = resp.dig(:data, :search, :pageInfo) || {}
          break unless client.auto_paginate && page.fetch(:hasNextPage, false)

          variables[:after] = page[:endCursor]
        end

        results
      end
    end
  end
end
