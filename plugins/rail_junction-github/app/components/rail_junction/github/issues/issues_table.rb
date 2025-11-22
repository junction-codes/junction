# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Issues
        # Table of issues for a repository.
        class IssuesTable < ::Components::Base
          # Initialize a new component.
          #
          # @param entity [ApplicationRecord] The entity the repository is related
          #   to.
          # @param issues [Array<Hash>] The issues to render.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(entity:, issues:, **user_attrs)
            @entity = entity
            @issues = issues
            super(**user_attrs)
          end

          def view_template
            Components::RepoTableHeader(entity: @entity, path: "issues")
            ::Components::Table(**attrs) do |table|
              table.header do |header|
                header.row do |row|
                  row.cell { "ID" }
                  row.cell { "Title" }
                  row.cell { "Creator" }
                  row.cell { "Assignees" }
                  row.cell { "Created" }
                  row.cell { "Updated" }
                  row.cell { "Comments" }
                end
              end

              table.body do
                @issues.each do |issue|
                  IssueRow(issue:)
                end
              end
            end
          end
        end
      end
    end
  end
end
