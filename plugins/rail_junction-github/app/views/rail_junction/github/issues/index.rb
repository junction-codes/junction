# frozen_string_literal: true

module RailJunction
  module Github
    # Displays a list of GitHub issues for a given entity.
    #
    # @todo Implement search, filtering, refresh, and pagination.
    class Views::Issues::Index < ::Components::Base
      def initialize(entity:, frame_id:, issues:)
        @entity = entity
        @frame_id = frame_id
        @issues = issues
      end

      def view_template
        turbo_frame_tag(@frame_id) do
          div(class: "bg-white dark:bg-gray-800 rounded-xl shadow pb-5") do
            Components::Issues::IssuesTable(entity: @entity, issues: @issues)
          end
        end
      end
    end
  end
end
