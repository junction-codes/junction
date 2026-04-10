# frozen_string_literal: true

module Junction
  module Components
    module Breadcrumb
      # UI component to display a breadcrumb trail.
      class Breadcrumb < Base
        def view_template(&)
          nav(**attrs, &)
        end

        private

        def default_attrs
          {
            aria: { label: "breadcrumb" },
            class: "px-6 pt-3"
          }
        end
      end
    end
  end
end
