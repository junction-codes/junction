# frozen_string_literal: true

require_relative "base"

module RailJunction
  module Github
    module Components
      class PullRequestsTab < Base
        def template
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
              client.pull_requests.each do |pr|
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

        private

        def value
          @value ||= client.issues.count
        end
      end
    end
  end
end
