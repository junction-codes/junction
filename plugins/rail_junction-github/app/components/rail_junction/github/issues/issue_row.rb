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
          # @param slug [String] Slug of the repository the issue belongs to.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(issue:, slug:, **user_attrs)
            @issue = issue
            @slug = slug
            super(**user_attrs)
          end

          def view_template
            ::Components::TableRow(**attrs) do |row|
              row.cell do
                div(class: "flex items-center space-x-4") do
                  div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                    icon("bug", class: "h-6 w-6 #{icon_color}")
                  end

                  div do
                    div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                      Link(href: @issue.html_url, class: "p-0") { @issue.title }
                    end

                    div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") do
                      "#{@slug}##{@issue.number}"
                    end
                  end
                end
              end

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

          private

          # Determine the color of the icon based on the issue state.
          #
          # @return [String] The color for the icon.
          def icon_color
            if @issue.state == "open"
              "text-success"
            elsif @issue.state_reason == "completed"
              "text-purple-500"
            else
              "text-alert"
            end
          end
        end
      end
    end
  end
end
