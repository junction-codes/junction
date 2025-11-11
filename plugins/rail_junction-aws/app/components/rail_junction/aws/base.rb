# frozen_string_literal:

module RailJunction
  module Aws
    module Components
      class Base < ::Components::Base
        def initialize(object:, **user_attrs)
          @object = object

          super(**user_attrs)
        end

        def render?
          true
        end

        def template; end

        def view_template
          return unless render?

          template
        end
      end
    end
  end
end
