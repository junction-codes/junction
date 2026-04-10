# frozen_string_literal: true

module Junction
  module Components
    module Dialog
      # UI component to display a dialog middle section.
      class Middle < Base
        def view_template(&)
          div(**attrs, &)
        end

        private

        def default_attrs
          {
            class: "py-4"
          }
        end
      end
    end
  end
end
