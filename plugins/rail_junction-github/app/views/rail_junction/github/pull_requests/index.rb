# frozen_string_literal: true

module RailJunction
  module Github
    class Views::PullRequests::Index < ::Components::Base
      def initialize(entity:, pull_requests:, frame_id:)
        @entity = entity
        @pull_requests = pull_requests
        @frame_id = frame_id
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          render ::Components::Table do |table|
            table.header do |header|
              header.row do |row|
                row.cell { "ID" }
                row.cell { "Title" }
                row.cell { "Creator" }
                row.cell { "Created" }
                row.cell { "Last Updated" }
              end
            end

            table.body do |body|
              @pull_requests.each do |pr|
                body.row do |row|
                  row.cell { pr.id }
                  row.cell { Link(href: pr.html_url) { pr.title } }
                  row.cell { Link(href: pr.user.html_url) { pr.user.login } }
                  row.cell do
                    time(datetime: pr.created_at.to_formatted_s(:datetime),
                         title: pr.created_at.to_formatted_s(:datetime)) do
                      "#{time_ago_in_words(pr.created_at)} ago"
                    end
                  end

                  row.cell do
                    time(datetime: pr.updated_at.to_formatted_s(:datetime),
                         title: pr.created_at.to_formatted_s(:datetime)) do
                      "#{time_ago_in_words(pr.updated_at)} ago"
                    end
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
