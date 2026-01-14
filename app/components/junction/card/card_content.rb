# frozen_string_literal: true

module Junction
  module Components
    # UI component to display the content section of a card.
    class CardContent < Base
      def view_template(&)
        div(**attrs, &)
      end

      def description(*, **, &)
        render CardDescription.new(*, **, &)
      end

      private

      def default_attrs
        {
          class: "p-6 pt-0"
        }
      end
    end
  end
end
