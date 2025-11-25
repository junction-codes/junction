# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    # Service to interact with GitHub teams.
    class TeamService < ClientService
      PULL_REQUESTS_QUERY = <<~GRAPHQL
        query($q: String!, $after: String, $limit: Int = 10) {
          search(query: $q, type: ISSUE, first: $limit, after: $after) {
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

      # Initialize the service.
      #
      # @param slug [String] The team slug in the format "org/team-name".
      def initialize(slug:)
        @slug = slug
      end

      # Retrieve pull requests assigned to the team.
      #
      # @param state [Symbol] The state of the pull requests to retrieve.
      # @return [Array<Hash>] List of pull requests.
      def pull_requests(state: :open)
        org, team = @slug.split("/", 2)
        variables = { q: "team-review-requested:#{org}/#{team} type:pr", limit: DEFAULT_PAGE_SIZE }
        variables[:q] += " state:#{state}" unless state == :all

        graphql(query: PULL_REQUESTS_QUERY, variables:)
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
