# frozen_string_literal: true

module Junction
  module Components
    module Tabs
      class TabsTrigger < Base
        def initialize(value:, as: :button, **user_attrs)
          @value = value
          @as = as

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
            class: [
              "cursor-pointer inline-flex items-center justify-center",
              "whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium",
              "ring-offset-background transition-all",
              "disabled:pointer-events-none disabled:opacity-50",
              "aria-disabled:pointer-events-none aria-disabled:opacity-50",
              "aria-disabled:cursor-not-allowed",
              "data-[state=active]:bg-muted data-[state=active]:text-foreground",
              "data-[state=active]:shadow",
              "dark:data-[state=inactive]:hover:bg-gray-700/50",
              "focus-visible:outline-none focus-visible:ring-2",
              "focus-visible:ring-ring focus-visible:ring-offset-2"
            ]
          }

          base[:type] = :button unless @as == :a
          base
        end
      end
    end
  end
end
