# frozen_string_literal: true

require "octokit"

Octokit.configure do |c|
  c.access_token = ENV["GITHUB_TOKEN"] if ENV["GITHUB_TOKEN"]
end
