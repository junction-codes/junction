# frozen_string_literal: true

module Junction
  module Components
    module Card
      # UI component to display a card title.
      class CardTitle < Base
        LEVELS = { 1 => :h1, 2 => :h2, 3 => :h3, 4 => :h4 }.freeze

        # Initializes a new component.
        #
        # @param level [Integer] Heading level for the title.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(level: 2, **user_attrs)
          @level = level

          super(**user_attrs)
        end

        def view_template(&)
          send(LEVELS.fetch(@level), **attrs, &)
        end

        private

        def default_attrs
          {
            class: "font-semibold leading-none tracking-tight"
          }
        end
      end
    end
  end
end
