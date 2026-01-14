# frozen_string_literal: true

module Junction
  module Components
    class TabsList < Base
      def view_template(&)
        div(**attrs, &)
      end

      def trigger(*, **, &)
        render TabsTrigger.new(*, **, &)
      end

      private

      def default_attrs
        {
          class: "inline-flex h-9 items-center justify-center rounded-lg bg-background p-1 text-muted-foreground gap-2"
        }
      end
    end
  end
end
