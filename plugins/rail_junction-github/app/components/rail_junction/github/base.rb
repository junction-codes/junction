# frozen_string_literal:

module RailJunction
  module Github
    module Components
      class Base < ::Components::Base
        def initialize(object:, **user_attrs)
          @entity = object

          super(**user_attrs)
        end

        def template; end

        def view_template
          template
        end

        private

        def service
          @service ||= RepositoryService.new(slug:)
        end

        def slug
          @entity.annotations.fetch(Engine::ANNOTATION_PROJECT_SLUG, nil)
        end

        def status
          case value
          when 0
            :healthy
          when 1..5
            :warning
          when 6..10
            :critical
          else
            :danger
          end
        end

        def value
          raise NotImplementedError, "You must implement the value method in the subclass"
        end
      end
    end
  end
end
