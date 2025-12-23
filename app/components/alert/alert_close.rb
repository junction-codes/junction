# frozen_string_literal: true

module Components
  # UI component to display a close button for an alert.
  class AlertClose < Base
    def view_template(&)
      Button(**attrs) do
        icon("x", class: "h-4 w-4")
        span(class: "sr-only") { t("components.alert.close") }
      end
    end

    private

    def default_attrs
      {
        data_action: "click->alert#dismiss",
        class: "absolute end-4 top-4 hover:opacity-70 focus:outline-none " \
          "focus:ring-2 focus:ring-ring focus:ring-offset-2 " \
          "disabled:pointer-events-none data-[state=open]:bg-accent " \
          "data-[state=open]:text-muted-foreground px-1.5!",
        icon: true,
        size: :sm,
        variant: :ghost
      }
    end
  end
end
