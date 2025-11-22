# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Actions
        # Table of actions for a repository.
        class WorkflowRunsTable < ::Components::Base
          # Initialize a new component.
          #
          # @param entity [ApplicationRecord] The entity the repository is related to.
          # @param workflow_runs [Array<Hash>] The workflow runs to render.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(entity:, workflow_runs:, **user_attrs)
            @entity = entity
            @workflow_runs = workflow_runs
            super(**user_attrs)
          end

          def view_template
            Components::RepoTableHeader(entity: @entity, path: "actions")
            ::Components::Table(**attrs) do |table|
              table.header do |header|
                header.row do |row|
                  row.cell { "ID" }
                  row.cell { "Message" }
                  row.cell { "Source" }
                  row.cell { "Status" }
                  row.head(class: "relative") do
                    span(class: "sr-only") { "Actions" }
                  end
                end
              end

              table.body do
                @workflow_runs.each do |run|
                  WorkflowRunRow(workflow_run: run)
                end
              end
            end
          end
        end
      end
    end
  end
end
