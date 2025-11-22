# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      # Header for a table showing GitHub repository information.
      class RepoTableHeader < ::Components::Base
        # Initialize a new component.
        #
        # @param entity [ApplicationRecord] The entity the repository is related
        #   to.
        # @param path [String] An optional path to append to the repository URL.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
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

        def default_attrs
          {
            class: "p-5 flex items-center"
          }
        end

        # URL for the link to the repository.
        #
        # @return string
        def href
          "https://github.com/#{slug}" + (@path ? "/#{@path}" : "")
        end

        # Project slug for the repository.
        #
        # @return string
        def slug
          @entity.annotations[Engine::ANNOTATION_PROJECT_SLUG]
        end
      end
    end
  end
end
