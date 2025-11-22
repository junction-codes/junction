# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module PullRequests
        # Individual table row for a repository pull request.
        class PullRequestRow < ::Components::Base
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
              row.cell { @pull_request.id }
              row.cell { Link(href: @pull_request.html_url) { @pull_request.title } }
              row.cell { Components::GithubUserLink(user: @pull_request.user) }
              row.cell do
                render ::Components::RelativeTime.new(time: @pull_request.created_at)
              end

              row.cell do
                render ::Components::RelativeTime.new(time: @pull_request.updated_at)
              end
            end
          end
        end
      end
    end
  end
end
