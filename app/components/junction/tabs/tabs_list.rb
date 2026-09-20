# frozen_string_literal: true

module Junction
  module Components
    module Tabs
      class TabsList < Base
        VARIANTS = {
          pill: "inline-flex h-9 items-center justify-center rounded-lg " \
                "bg-background p-1 text-muted-foreground gap-2",
          underline: "flex items-center gap-8 border-b border-border"
        }.freeze

        # Initializes the component.
        #
        # @param variant [Symbol] One of {VARIANTS}.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(variant: :pill, **user_attrs)
          @variant = variant

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs, &)
        end

        def trigger(**, &)
          render TabsTrigger.new(variant: @variant, **, &)
        end

        private

        def default_attrs
          { class: VARIANTS.fetch(@variant) }
        end
      end
    end
  end
end
