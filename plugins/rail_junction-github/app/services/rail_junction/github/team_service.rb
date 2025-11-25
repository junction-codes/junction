# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    # Service to interact with GitHub teams.
    class TeamService < ClientService
      # Initialize the service.
      #
      # @param slug [String] The team slug in the format "org/team-name".
      def initialize(slug:)
        @slug = slug
        # @org, @name = slug.split("/", 2)
      end

      def pull_requests(state: :open)
        org, team = @slug.split("/", 2)
        query = <<~GRAPHQL
          query($q: String!, $after: String) {
            search(query: $q, type: ISSUE, first: 100, after: $after) {
              pageInfo { hasNextPage endCursor }
              nodes {
                ... on PullRequest {
                  number
                  title
                  state
                  merged_at: mergedAt
                  html_url: url
                  created_at: createdAt
                  updated_at: updatedAt
                  draft: isDraft
                  user: author {
                    login
                    avatar_url: avatarUrl
                    html_url: url
                  }
                  repo: repository {
                    full_name: nameWithOwner
                  }
                }
              }
            }
          }
        GRAPHQL

        q = "team-review-requested:#{org}/#{team} type:pr"
        q += " state:#{state}" unless state == :all
        results = []
        after = nil
        loop do
          variables = { q: q }
          variables[:after] = after if after
          # resp = client.graphql(query, variables)
          resp = client.post '/graphql', { query:, variables: }.to_json
          results.concat(resp.dig(:data, :search, :nodes) || [])
          page = resp.dig(:data, :search, :pageInfo) || {}

          break unless page.fetch(:hasNextPage, false)

          after = page[:endCursor]
        end

        results
      end

      # Retrieve details of the team.
      #
      # @return [Sawyer::Resource] Details of the team.
      def team
        client.team_by_name(*@slug.split("/", 2))
      end
    end
  end
end
