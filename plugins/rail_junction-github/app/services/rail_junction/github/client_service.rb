# frozen_string_literal: true

require "octokit"

module RailJunction
  module Github
    class ClientService
      def initialize(slug:)
        @slug = slug
      end

      def self.from_url(url)
        new(slug: Octokit::Repository.from_url(url))
      end

      def repo
        client.repository(@slug)
      end

      def workflows
        client.workflows(@slug)
      end

      def issues(state: :open)
        client.issues(@slug, state:).reject { |issue| issue.pull_request }
      end

      def pull_requests(state: :open)
        client.pull_requests(@slug, state:)
      end

      private

      def client
        @client ||= Octokit::Client.new(auto_paginate: true)
      end
    end
  end
end
