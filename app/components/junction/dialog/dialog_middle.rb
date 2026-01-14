# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a dialog middle section.
    class DialogMiddle < Base
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
