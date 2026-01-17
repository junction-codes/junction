# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a dialog trigger.
    class DialogTrigger < Base
      def view_template(&)
        div(**attrs, &)
      end

      private

      def default_attrs
        {
          data: {
            action: "click->ruby-ui--dialog#open"
          },
          class: "inline-block"
        }
      end
    end
  end
end
