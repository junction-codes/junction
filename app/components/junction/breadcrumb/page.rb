# frozen_string_literal: true

module Junction
  module Components
    module Breadcrumb
      # UI component to display the current page in a breadcrumb trail.
      class Page < Base
        # Initializes the component.
        #
        # @param current [Boolean] Whether this crumb is the page being viewed.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(current: true, **user_attrs)
          @current = current

          super(**user_attrs)
        end

        def view_template(&)
          span(**attrs, &)
        end

        private


        def default_attrs
          attrs = { class: "font-normal text-foreground" }
          attrs[:aria] = { current: "page" } if @current

          attrs
        end
      end
    end
  end
end
