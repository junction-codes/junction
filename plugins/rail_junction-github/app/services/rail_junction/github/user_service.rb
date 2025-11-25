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

      # Retrieve details of the user.
      #
      # @return [Sawyer::Resource] Details of the user.
      def user
        client.user(@username)
      end
    end
  end
end
