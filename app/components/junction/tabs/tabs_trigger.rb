# frozen_string_literal: true

module Junction
  module Components
    module Tabs
      class TabsTrigger < Base
        BASE_CLASSES = [
          "cursor-pointer inline-flex items-center whitespace-nowrap",
          "ring-offset-background transition-all",
          "disabled:pointer-events-none disabled:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "aria-disabled:cursor-not-allowed",
          "focus-visible:outline-none focus-visible:ring-2",
          "focus-visible:ring-ring focus-visible:ring-offset-2"
        ].freeze

        VARIANTS = {
          pill: [
            "justify-center rounded-md px-3 py-1 text-sm font-medium",
            "data-[state=active]:bg-muted data-[state=active]:text-foreground",
            "data-[state=active]:shadow",
            "dark:data-[state=inactive]:hover:bg-gray-700/50"
          ],
          underline: [
            "items-baseline -mb-px pb-2 border-b-2 border-transparent text-[13.5px]",
            "font-medium text-text-tertiary",
            "hover:text-foreground hover:border-border",
            "data-[state=active]:font-semibold",
            "data-[state=active]:text-foreground",
            "data-[state=active]:border-accent-muted"
          ]
        }.freeze

        # Initializes the component.
        #
        # @param value [String] The pane this trigger shows.
        # @param as [Symbol] `:button`, or `:a` for a trigger that is a link.
        # @param variant [Symbol] One of {VARIANTS}.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(value:, as: :button, variant: :pill, **user_attrs)
          @value = value
          @as = as
          @variant = variant

          super(**user_attrs)
        end

        def view_template(&)
          if @as == :a
            a(**attrs, &)
          else
            button(**attrs, &)
          end
        end

        private

        def default_attrs
          base = {
            data: {
              ruby_ui__tabs_target: "trigger",
              action: "click->ruby-ui--tabs#show",
              value: @value
            },
            class: [ *BASE_CLASSES, *VARIANTS.fetch(@variant) ]
          }

          base[:type] = :button unless @as == :a
          base
        end
      end
    end
  end
end
