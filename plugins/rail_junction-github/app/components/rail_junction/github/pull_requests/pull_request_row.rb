# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module PullRequests
        # Individual table row for a repository pull request.
        class PullRequestRow < ::Components::Base
          ICON_CLOSED = %w[git-pull-request-closed text-alert].freeze
          ICON_MERGED = %w[git-pull-request text-purple-500].freeze
          ICON_OPEN = %w[git-pull-request-arrow text-success].freeze
          ICON_OPEN_DRAFT = %w[git-pull-request-draft text-gray-500].freeze

          # Initialize a new component.
          #
          # @param pull_request [Hash] Pull request to render.
          # @param user_attrs [Hash] Additional HTML attributes for the component.
          def initialize(pull_request:, **user_attrs)
            @pull_request = pull_request
            super(**user_attrs)
          end

          def view_template
            ::Components::TableRow(**attrs) do |row|
              row.cell do
                div(class: "flex items-center space-x-4") do
                  div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                    render_icon
                  end

                  div do
                    div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                      Link(href: @pull_request.html_url, class: "p-0") { @pull_request.title }
                    end

                    div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") do
                      "#{repository}##{@pull_request.number}"
                    end
                  end
                end
              end

              row.cell { Components::GithubUserLink(user: @pull_request.user) }
              row.cell do
                render ::Components::RelativeTime.new(time: @pull_request.created_at)
              end

              row.cell do
                render ::Components::RelativeTime.new(time: @pull_request.updated_at)
              end
            end
          end

          private

          # Get the full repository name for the pull request.
          #
          # @return [String] Full repository name or nil if not available.
          def repository
            @repository ||= @pull_request.repo&.full_name || @pull_request.base&.repo&.full_name
          end

          # Render the appropriate icon based on the state of the pull request.
          def render_icon
            name, color = if @pull_request.state.to_s.downcase == "open"
              @pull_request.draft ? ICON_OPEN_DRAFT : ICON_OPEN
            else
              @pull_request.merged_at.present? ? ICON_MERGED : ICON_CLOSED
            end

            icon(name, class: "h-6 w-6 #{color}")
          end
        end
      end
    end
  end
end
