# frozen_string_literal: true

module RailJunction
  module Github
    class ActionsController < ApplicationController
      before_action :set_component

      def index
        render RailJunction::Github::Views::Actions::Index.new(
          object: @component,
          workflows: client.workflows.workflows,
          frame_id: "component_github_actions",
        )
      end

      private

      def set_component
        @component = @object = ::Component.find(params[:component_id])
      end
    end
  end
end
