# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    # Service to interact with a specific GitHub repository.
    class RepositoryService < ClientService
      DEFAULT_PAGE_SIZE = 10

      # Retrieve issues for the repository.
      #
      # The GitHub API returns both issues and pull requests in the issues
      # endpoint. This method filters out pull requests to return only issues.
      #
      # @param state [Symbol] The state of the issues to retrieve.
      # @return [Array<Sawyer::Resource>] List of issues.
      def issues(state: :open)
        client.issues(@slug, state:, per_page: DEFAULT_PAGE_SIZE).reject { |issue| issue.pull_request }
      end

      # Retrieve pull requests for the repository.
      #
      # @param state [Symbol] The state of the pull requests to retrieve.
      # @return [Array<Sawyer::Resource>] List of pull requests.
      def pull_requests(state: :open)
        client.pull_requests(@slug, state:, per_page: DEFAULT_PAGE_SIZE)
      end

      # Retrieve details about the repository.
      #
      # @return [Sawyer::Resource] Repository details.
      def repo
        client.repository(@slug)
      end

      # Retrieve workflow runs for the repository.
      #
      # @return [Array<Sawyer::Resource>] List of workflow runs.
      def workflow_runs
        client.repository_workflow_runs(@slug, per_page: DEFAULT_PAGE_SIZE).workflow_runs
      end

      # Retrieve workflows for the repository.
      #
      # @return [Array<Sawyer::Resource>] List of workflows.
      def workflows
        client.workflows(@slug).workflows
      end
    end
  end
end
