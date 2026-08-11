# frozen_string_literal: true

module Junction
  module Components
    module Alert
      # UI component to display important messages to users.
      class Alert < Base
        BASE_CLASSES = "backdrop-blur relative w-full ring-1 ring-inset " \
                       "rounded-lg px-4 py-4 text-sm " \
                       "[&>svg+div]:translate-y-[-3px] [&>svg]:absolute " \
                       "[&>svg]:start-4 [&>svg]:top-4 [&>svg~*]:ps-8"
        COLORS = {
          alert: "ring-destructive/20 bg-destructive/10 text-destructive [&>svg]:text-destructive/80",
          default: "ring-blue-900/20 bg-blue-900/20 text-foreground [&>svg]:opacity-80",
          success: "ring-success/20 bg-success/30 text-success [&>svg]:text-success/80",
          warning: "ring-warning/20 bg-warning/5 text-warning [&>svg]:text-warning/80"
        }.freeze
        ICONS = {
          alert: "circle-minus",
          default: "info",
          success: "circle-check",
          warning: "triangle-alert"
        }.freeze
        VARIANTS = %i[ alert default success warning ].freeze

        # Initializes a new component.
        #
        # @param variant [Symbol] Alert variant to display.
        # @param dismissible [Boolean] Whether the alert can be dismissed by
        #   the user.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(variant: :default, dismissible: true, **user_attrs)
          @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :default
          @dismissible = dismissible

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs) do
            icon(ICONS[@variant], class: "h-6 w-6")
            AlertTitle { t(".titles.#{@variant}") }

            yield

            render AlertClose.new if @dismissible
          end
        end

        def description(...)
          AlertDescription(...)
        end

        private

        def default_attrs
          attrs = { class: [ BASE_CLASSES, COLORS[@variant] ] }
          attrs[:data] = { controller: "alert" } if @dismissible

          attrs
        end
      end
    end
  end
end
