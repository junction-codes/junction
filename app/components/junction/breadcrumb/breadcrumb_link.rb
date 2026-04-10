# frozen_string_literal: true

module Junction
  module Components
    module Breadcrumb
      # UI component to display a link in a breadcrumb trail.
      class BreadcrumbLink < Base
        def initialize(href: "#", **user_attrs)
          @href = href

          super(**user_attrs)
        end

        def view_template(&)
          a(href: @href, **attrs, &)
        end

        private

        def default_attrs
          {
            class: "transition-colors hover:text-foreground"
          }
        end
      end
    end
  end
end
