# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module PullRequests
        # Table of pull requests for a repository.
        class PullRequestsTable < ::Components::Base
          # Initialize a new component.
          #
          # @param entity [ApplicationRecord] The entity the repository is related
          #   to.
          # @param pull_requests [Array<Hash>] The pull requests to render.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(entity:, pull_requests:, **user_attrs)
            @entity = entity
            @pull_requests = pull_requests
            super(**user_attrs)
          end

          def view_template
            Components::RepoTableHeader(entity: @entity, path: "pulls")
            ::Components::Table(**attrs) do |table|
              table.header do |header|
                header.row do |row|
                  row.cell { "ID" }
                  row.cell { "Title" }
                  row.cell { "Creator" }
                  row.cell { "Created" }
                  row.cell { "Last Updated" }
                end
              end

              table.body do
                @pull_requests.each do |pull_request|
                  PullRequestRow(pull_request:)
                end
              end
            end
          end
        end
      end
    end
  end
end
