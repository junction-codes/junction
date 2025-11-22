# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Actions
        # Individual table row for a repository workflow run.
        class WorkflowRunRow < ::Components::Base
          # Initialize a new component.
          #
          # @param workflow_run [Hash] Workflow run to display.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(workflow_run:, **user_attrs)
            @workflow_run = workflow_run
            super(**user_attrs)
          end

          def view_template
            ::Components::TableRow(**attrs) do |row|
              row.cell { @workflow_run.id }
              row.cell { Link(href: @workflow_run.html_url) { @workflow_run.display_title } }
              row.cell do
                p(class: 'pb-2') { @workflow_run.head_branch }
                p { @workflow_run.head_sha }
              end

              row.cell { WorkflowRunBadge(workflow_run: @workflow_run) }

              row.cell(class: "text-right") do
                # TODO: Implement actions.
                Link(variant: :disabled, title: "Rerun workflow") { icon('rotate-ccw') }
              end
            end
          end
        end
      end
    end
  end
end
