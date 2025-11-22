# frozen_string_literal: true

module RailJunction
  module Github
    class IssuesController < ApplicationController
      before_action :set_component

      def index
        render RailJunction::Github::Views::Issues::Index.new(
          entity: @component,
          issues: RepositoryService.new(slug:).issues,
          frame_id: "component_github_issues",
        )
      end

      private

      def set_component
        @component = @entity = ::Component.find(params[:component_id])
      end
    end
  end
end
