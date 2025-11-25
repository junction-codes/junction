# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      # Header for a table showing GitHub team information.
      class TeamTableHeader < ::Components::Base
        DEFAULT_ATTRS = { class: "p-5 flex items-center" }.freeze

        # Initialize a new component.
        #
        # @param entity [ApplicationRecord] The entity the team is related to.
        # @param path [String] An optional path to append to the team URL.
        # @param user_attrs [Hash] Additional attributes for the component.
        def initialize(entity:, path: nil, **user_attrs)
          @entity = entity
          @path = path
          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            icon("github")
            Link(href:, target: "_blank", rel: "noopener", class: "font-bold") do
              slug
            end
          end
        end

        private

        # URL for the link to the team.
        #
        # @return string
        def href
          org, name = slug.split("/")
          "https://github.com/orgs/#{org}/teams/#{name}" + (@path ? "/#{@path}" : "")
        end

        # Organization and team slug for the team.
        #
        # @return string
        def slug
          @entity.annotations[Engine::ANNOTATION_TEAM_SLUG]
        end
      end
    end
  end
end
