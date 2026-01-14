# frozen_string_literal: true

module Junction
  module Components
    # UI component to display a fallback avatar when no image is available.
    class AvatarFallback < Base
      def view_template(&)
        span(**attrs, &)
      end

      private

      def default_attrs
        {
          class: "flex h-full w-full items-center justify-center rounded-full bg-muted"
        }
      end
    end
  end
end
