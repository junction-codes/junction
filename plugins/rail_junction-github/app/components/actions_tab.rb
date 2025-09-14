# frozen_string_literal: true

require_relative "base"

module RailJunction
  module Github
    module Components
      class ActionsTab < Base
        def template
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
              client.workflows.workflows.each do |workflow|
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
end
