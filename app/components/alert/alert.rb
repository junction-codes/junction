# frozen_string_literal: true

module Components
  class Alert < Base
    def initialize(variant: nil, **attrs)
      @variant = variant

      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        alert_icon
        title
        yield
        close_button
      end
    end

    def description(*, **, &)
      render AlertDescription.new(*, **, &)
    end

    private

    def alert_icon
      icon = case @variant.to_sym
      when :alert then "circle-minus"
      when :success then "circle-check"
      when :warning then "triangle-alert"
      else "info"
      end

      icon(icon, class: "h-6 w-6")
    end

    def close_button
      render Button.new(
        variant: :ghost,
        icon: true,
        size: :sm,
        class: "absolute end-4 top-4 hover:opacity-70 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground px-1.5!",
        data_action: "click->alert#dismiss"
      ) do
        icon("x", class: "h-4 w-4")
        span(class: "sr-only") { "Close" }
      end
    end

    def colors
      case @variant.to_sym
      when :alert
        "ring-destructive/20 bg-destructive/10 text-destructive [&>svg]:text-destructive/80"
      when :success
        "ring-success/20 bg-success/30 text-success [&>svg]:text-success/80"
      when :warning
        "ring-warning/20 bg-warning/5 text-warning [&>svg]:text-warning/80"
      else
        "ring-blue-900/20 bg-blue-900/20 text-foreground [&>svg]:opacity-80"
      end
    end

    def title
      title = case @variant.to_sym
      when :alert
                "Alert"
      when :success
                "Success"
      when :warning
                "Warning"
      else
                "Notice"
      end

      render AlertTitle { title }
    end

    def default_attrs
      base_classes = "backdrop-blur relative w-full ring-1 ring-inset rounded-lg px-4 py-4 text-sm [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:start-4 [&>svg]:top-4 [&>svg~*]:ps-8"
      {
        class: [ base_classes, colors ],
        data: { controller: "alert" }
      }
    end
  end
end
