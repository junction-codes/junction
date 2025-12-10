# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Actions
        # Individual table row for a repository workflow run.
        class WorkflowRunRow < ::Components::Base
          DEFAULT_COLOR = "text-gray-500"
          CONCLUSION_COLORS = {
            "action_required" => "text-alert",
            "cancelled" => "text-gray-500",
            "failure" => "text-alert",
            "neutral" => "text-gray-500",
            "success" => "text-success",
            "skipped" => "text-gray-500",
            "timed_out" => "text-alert",
            "stale" => "text-gray-500"
          }.freeze

          STATUS_COLORS = {
            "action_required" => "text-alert",
            "cancelled" => "text-gray-500",
            "failure" => "text-alert",
            "in_progress" => "text-warning",
            "pending" => "text-warning",
            "queued" => "text-warning",
            "requested" => "text-warning",
            "skipped" => "text-gray-500",
            "success" => "text-success",
            "timed_out" => "text-alert"
          }.freeze

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
              row.cell do
                div(class: "flex items-center space-x-4") do
                  div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                    icon("workflow", class: "h-6 w-6 #{icon_color}")
                  end

                  div do
                    div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                      Link(href: @workflow_run.html_url, class: "p-0") { @workflow_run.display_title }
                    end

                    div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") do
                      "#{@workflow_run.repository.full_name}##{@workflow_run.run_number}"
                    end
                  end
                end
              end

              row.cell do
                p(class: "pb-2") { @workflow_run.head_branch }
                p { @workflow_run.head_sha }
              end

              row.cell { WorkflowRunBadge(workflow_run: @workflow_run) }

              row.cell(class: "text-right") do
                # TODO: Implement actions.
                Link(variant: :disabled, title: "Rerun workflow") { icon("rotate-ccw") }
              end
            end
          end

          private

          # Determine the color of the icon based on the run's state.
          #
          # @return [String] The color for the icon.
          def icon_color
            if @workflow_run.conclusion.present?
              return CONCLUSION_COLORS.fetch(@workflow_run.conclusion, DEFAULT_COLOR)
            end

            STATUS_COLORS.fetch(@workflow_run.status, DEFAULT_COLOR)
          end
        end
      end
    end
  end
end
