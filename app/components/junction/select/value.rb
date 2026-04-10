# frozen_string_literal: true

module Junction
  module Components
    module Select
      class Value < Base
        def initialize(placeholder: nil, **user_attrs)
          @placeholder = placeholder

          super(**user_attrs)
        end

        def view_template(&block)
          span(**attrs) do
            block ? block.call : @placeholder
          end
        end

        private

        def default_attrs
          {
            data: {
              ruby_ui__select_target: "value"
            },
            class: "truncate pointer-events-none"
          }
        end
      end
    end
  end
end
