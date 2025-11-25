# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Teams
        # Base class for team related components.
        #
        # @abstract
        class Base < ::Components::Base
          attr_reader :entity

          # Initialize a new component.
          #
          # `object` is deprecated but is still supported for compatibility. You
          # should not rely on this parameter, and instead use `entity`.
          #
          # @param object [ApplicationRecord] The entity representing the group.
          # @param entity [ApplicationRecord] The entity representing the group.
          # @param team [Hash] The GitHub team data, if already loaded.
          # @param user_attrs [Hash] Additional attributes for the component.
          #
          # @todo Require `entity` instead of `object` once all components have been updated.
          def initialize(object: nil, entity: nil, team: nil, **user_attrs)
            @entity = entity || object
            raise ArgumentError, "Entity is required" unless @entity

            @team = team
            super(**user_attrs)
          end

          private

          # Service used to fetch team data.
          #
          # @return [TeamService]
          def service
            @service ||= TeamService.new(slug:)
          end

          # Team data from GitHub.
          #
          # @return [Hash]
          def team
            @team ||= service.team
          end

          # Team slug from the group's annotations.
          #
          # @return [String]
          def slug
            @slug ||= @entity.annotations[Engine::ANNOTATION_TEAM_SLUG]
          end
        end
      end
    end
  end
end
