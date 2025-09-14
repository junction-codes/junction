# frozen_string_literal: true

module RailJunction
  module Github
    class Views::Actions::Index < ::Components::Base
      def initialize(object:, workflows:, frame_id:)
        @object = object
        @workflows = workflows
        @frame_id = frame_id
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          render ::Components::Table do |table|
            table.header do |header|
              header.row do |row|
                row.cell { "Workflow" }
                row.cell { "State" }
                row.cell { "Path" }
                row.head(class: "relative") do
                  span(class: "sr-only") { "Badge" }
                end
              end
            end

            table.body do |body|
              @workflows.each do |workflow|
                body.row do |row|
                  row.cell { workflow.name }
                  row.cell do
                    render ::Components::Badge.new(variant: badge_variant(workflow)) { workflow.state&.capitalize }
                  end

                  row.cell { workflow.path }
                  row.cell(class: "text-right") do
                    Link(href: workflow.html_url) { img(src: workflow.badge_url) }
                  end
                end
              end
            end
          end
        end
      end

      private

      private

      def badge_variant(workflow)
        case workflow.state
        when "active"
          :success
        when "disabled_manually", "disabled_inactivity"
          :warning
        when "deleted"
          :danger
        else
          :outline
        end
      end
    end
  end
end
