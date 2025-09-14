# frozen_string_literal:

module RailJunction
  module Github
    module Components
      class Base < ::Components::Base
        def initialize(object:, **user_attrs)
          @object = object

          super(**user_attrs)
        end

        def render?
          @object.repository_url.present?
        end

        def template; end

        def view_template
          return unless render?

          template
        end

        private

        def client
          @client ||= ClientService.from_url(@object.repository_url)
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
