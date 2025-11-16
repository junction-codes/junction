# frozen_string_literal: true

module RailJunction
  module Github
    # Displays a list of GitHub Actions workflows for a given entity.
    #
    # @todo Implement search, filtering, refresh, and pagination.
    class Views::Actions::Index < ::Components::Base
      BADGE_DEFAULT_WORKFLOW_CONCLUSION = :neutral
      BADGE_VARIANTS_WORKFLOW_CONCLUSION = {
        "action_required" => :danger,
        "cancelled" => :secondary,
        "failure" => :danger,
        "neutral" => :secondary,
        "success" => :success,
        "skipped" => :secondary,
        "timed_out" => :danger,
        "stale" => :secondary
      }.freeze

      BADGE_DEFAULT_WORKFLOW_STATUS = :outline
      BADGE_VARIANTS_WORKFLOW_STATUS = {
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

      def initialize(entity:, workflow_runs:, frame_id:)
        @entity = entity
        @workflow_runs = workflow_runs
        @frame_id = frame_id
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          render ::Components::Table do |table|
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

            table.body do |body|
              @workflow_runs.each do |run|
                body.row do |row|
                  row.cell { run.id }
                  row.cell { Link(href: run.html_url) { run.display_title } }
                  row.cell do
                    p(class: 'pb-2') { run.head_branch }
                    p { run.head_sha }
                  end

                  row.cell do
                    ::Components::Badge(variant: workflow_run_badge(run)) do
                      (run.conclusion || run.status).capitalize
                    end
                  end

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

      private

      # Variant to be used for the workflow badge.
      #
      # @param run [RailJunction::Github::Models::WorkflowRun] The workflow run.
      # @return [Symbol] The badge variant.
      def workflow_run_badge(run)
        pp("RUN CLASS", run.class)
        if run.conclusion.present?
          return BADGE_VARIANTS_WORKFLOW_CONCLUSION.fetch(
            run.conclusion,
            BADGE_DEFAULT_WORKFLOW_CONCLUSION
          )
        end

        BADGE_VARIANTS_WORKFLOW_STATUS.fetch(run.status, BADGE_DEFAULT_WORKFLOW_STATUS)
      end
    end
  end
end
