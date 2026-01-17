# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a user or entity's avatar.
    class Avatar < Base
      SIZES = {
        xs: "h-4 w-4 text-[0.5rem]",
        sm: "h-6 w-6 text-xs",
        md: "h-10 w-10 text-base",
        lg: "h-14 w-14 text-xl",
        xl: "h-20 w-20 text-3xl"
    }.freeze

      def initialize(size: :md, **user_attrs)
        @size = size

        super(**attrs)
      end

      def view_template(&)
        span(**attrs, &)
      end

      def fallback(*, **, &)
        render AvatarFallback.new(*, **, &)
      end

      def image(*, **, &)
        render AvatarImage.new(*, **, &)
      end

      private

      def default_attrs
        {
          class: [ "relative flex shrink-0 overflow-hidden rounded-full", SIZES[@size] ]
        }
      end
    end
  end
end
