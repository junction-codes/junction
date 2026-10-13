# frozen_string_literal: true

module Junction
  module Components
    module AuthCard
      # Renders a link inside the unauthenticated card.
      class AuthLink < Base
        CLASSES = "text-[13px] font-medium text-accent-strong"

        # Initializes the component.
        #
        # @param href [String] Where the link goes.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(href:, **user_attrs)
          @href = href

          super(**user_attrs)
        end

        def view_template(&)
          Link(href: @href, variant: :text, **attrs, &)
        end

        private

        def default_attrs
          { class: CLASSES }
        end
      end
    end
  end
end
