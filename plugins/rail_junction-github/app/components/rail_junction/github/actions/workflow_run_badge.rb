# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Actions
        # Badge for a GitHub Actions workflow run.
        class WorkflowRunBadge < ::Components::Base
          WORKFLOW_CONCLUSION_DEFAULT = :neutral
          WORKFLOW_CONCLUSION_VARIANTS = {
            "action_required" => :danger,
            "cancelled" => :secondary,
            "failure" => :danger,
            "neutral" => :secondary,
            "success" => :success,
            "skipped" => :secondary,
            "timed_out" => :danger,
            "stale" => :secondary
          }.freeze

          WORKFLOW_STATUS_DEFAULT = :outline
          WORKFLOW_STATUS_VARIANTS = {
            "action_required" => :danger,
            "cancelled" => :secondary,
            "failure" => :danger,
            "in_progress" => :yellow,
            "pending" => :yellow,
            "queued" => :yellow,
            "requested" => :yellow,
            "skipped" => :secondary,
            "success" => :success,
            "timed_out" => :danger
          }.freeze

          # Initialize a new component.
          #
          # @param workflow_run [Hash] Workflow run the badge is for.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(workflow_run:, **user_attrs)
            @workflow_run = workflow_run
            super(**user_attrs)
          end

          def view_template
            ::Components::Badge(variant:, **attrs) do
              (@workflow_run.conclusion || @workflow_run.status).capitalize
            end
          end

          private

          # Variant to be used for the workflow badge.
          #
          # @return [Symbol] The badge variant.
          def variant
            if @workflow_run.conclusion.present?
              return WORKFLOW_CONCLUSION_VARIANTS.fetch(
                @workflow_run.conclusion,
                WORKFLOW_CONCLUSION_DEFAULT
              )
            end

            WORKFLOW_STATUS_VARIANTS.fetch(@workflow_run.status,
                                                 WORKFLOW_STATUS_DEFAULT)
          end
        end
      end
    end
  end
end
