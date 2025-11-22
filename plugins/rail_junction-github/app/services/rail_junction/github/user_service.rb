# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    # Service to interact with GitHub users.
    class UserService < ClientService
      # Initialize the service.
      #
      # @param username [String] Login of the GitHub user.
      def initialize(username:)
        @username = username
      end

      # Retrieve issues for the repository.
      #
      # The GitHub API returns both issues and pull requests in the issues
      # endpoint. This method filters out pull requests to return only issues.
      #
      # @return [Sawyer::Resource] Details of the user.
      def user
        client.user(@username)
      end
    end
  end
end
