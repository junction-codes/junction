# frozen_string_literal: true

module Junction
  module Components
    module Dialog
      # UI component to display a dialog description.
      class DialogDescription < Base
        def view_template(&)
          p(**attrs, &)
        end

        private

        def default_attrs
          {
            class: "text-sm text-muted-foreground"
          }
        end
      end
    end
  end
end
