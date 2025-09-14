# frozen_string_literal: true

module RailJunction
  module Github
    class Views::PullRequests::Index < ::Components::Base
      def initialize(object:, pull_requests:, frame_id:)
        @object = object
        @pull_requests = pull_requests
        @frame_id = frame_id
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          render ::Components::Table do |table|
            table.header do |header|
              header.row do |row|
                row.cell { "Pull Request" }
                row.cell { "Opened" }
                row.head(class: "relative") do
                  span(class: "sr-only") { "View" }
                end
              end
            end

            table.body do |body|
              @pull_requests.each do |pr|
                body.row do |row|
                  row.cell { pr.title }
                  row.cell { pr.created_at }

                  row.cell(class: "text-right text-sm font-medium") do
                    Link(href: pr.html_url, class: "text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300") { "View" }
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
