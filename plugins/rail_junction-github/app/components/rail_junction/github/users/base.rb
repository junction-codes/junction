# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      module Users
        # Base class for user related components.
        #
        # @abstract
        class Base < ::Components::Base
          attr_reader :entity

          # Initialize a new component.
          #
          # `object` is deprecated but is still supported for compatibility. You
          # should not rely on this parameter, and instead use `entity`.
          #
          # @param object [ApplicationRecord] The entity representing the user.
          # @param entity [ApplicationRecord] The entity representing the user.
          # @param user [Hash] The GitHub user data, if already loaded.
          # @param user_attrs [Hash] Additional attributes for the component.
          #
          # @todo Require `entity` instead of `object` once all components have been updated.
          def initialize(object: nil, entity: nil, user: nil, **user_attrs)
            @entity = entity || object
            raise ArgumentError, "Entity is required" unless @entity

            @user = user
            super(**user_attrs)
          end

          private

          # Service used to fetch user data.
          #
          # @return [UserService]
          def service
            @service ||= UserService.new(username:)
          end

          # User data from GitHub.
          #
          # @return [Hash]
          def user
            @user ||= service.user
          end

          # Username of the user from the entity annotations.
          #
          # @return [String]
          def username
            @username ||= @entity.annotations[Engine::ANNOTATION_USER_LOGIN]
          end
        end
      end
    end
  end
end
