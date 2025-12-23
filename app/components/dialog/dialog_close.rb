# frozen_string_literal: true

module Components
  # UI component to display the close button for a dialog.
  class DialogClose < Base
    def view_template
      Button(**attrs) do
        icon("x", class: "h-4 w-4")
        span(class: "sr-only") { t("components.dialog.close") }
      end
    end


    private

    def default_attrs
      {
        data_action: "click->ruby-ui--dialog#dismiss",
        class: "absolute end-4 top-4 rounded-sm opacity-70 " \
               "ring-offset-background transition-opacity hover:opacity-100 " \
               "focus:outline-none focus:ring-2 focus:ring-ring " \
               "focus:ring-offset-2 disabled:pointer-events-none " \
               "data-[state=open]:bg-accent " \
               "data-[state=open]:text-muted-foreground",
        icon: true,
        size: :sm,
        variant: :ghost
      }
    end
  end
end
