# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a card footer.
    class CardFooter < Base
      def view_template(&)
        div(**attrs, &)
      end

      private

      def default_attrs
        {
          class: "items-center p-6 pt-0"
        }
      end
    end
  end
end
