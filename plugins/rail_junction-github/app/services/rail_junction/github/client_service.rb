# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    class ClientService
      def initialize(repo_full_name:)
        @repo_full_name = repo_full_name
      end

      def self.from_url(url)
        new(repo_full_name: Octokit::Repository.from_url(url))
      end

      def repo
        client.repository(@repo_full_name)
      end

      def workflows
        client.workflows(@repo_full_name)
      end

      # Method for fetching workflow runs
      def workflow_runs
        # ... logic to call @client.workflow_runs(@repo_full_name)
        # ... includes caching logic
      end

      def issues(state: :open)
        client.issues(@repo_full_name, state:).reject { |issue| issue.pull_request }
      end

      def pull_requests(state: :open)
        client.pull_requests(@repo_full_name, state:)
      end

      # Method for fetching repository stats
      def stats
        # ... logic for fetching contributors, languages, etc.
        # ... includes caching logic
      end

      private

      def client
        @client ||= Octokit::Client.new(auto_paginate: true)
      end
    end
  end
end
