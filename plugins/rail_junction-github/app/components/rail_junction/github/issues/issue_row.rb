# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Issues
        # Individual table row for a repository issue.
        class IssueRow < ::Components::Base
          # Initialize a new component.
          #
          # @param issue [Hash] Issue to render.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(issue:, **user_attrs)
            @issue = issue
            super(**user_attrs)
          end

          def view_template
            ::Components::TableRow(**attrs) do |row|
              row.cell { @issue.id }
              row.cell { Link(href: @issue.html_url) { @issue.title } }
              row.cell { Components::GithubUserLink(user: @issue.user) }

              row.cell do
                @issue.assignees.map do |assignee|
                  Components::GithubUserLink(user: assignee)
                end.join(", ")
              end

              row.cell do
                render ::Components::RelativeTime.new(time: @issue.created_at)
              end

              row.cell do
                render ::Components::RelativeTime.new(time: @issue.updated_at)
              end

              row.cell(class: "text-right") { @issue.comments }
            end
          end
        end
      end
    end
  end
end
