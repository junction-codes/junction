# frozen_string_literal: true

module Junction
  module Components
    # UI component to display the content section of a dialog.
    class DialogContent < Base
      SIZES = {
        xs: "max-w-sm",
        sm: "max-w-md",
        md: "max-w-lg",
        lg: "max-w-2xl",
        xl: "max-w-4xl",
        full: "max-w-full"
      }.freeze

      def initialize(size: :md, **user_attrs)
        @size = size

        super(**user_attrs)
      end

      def view_template
        template(data: { ruby_ui__dialog_target: "content" }) do
          div(data_controller: "ruby-ui--dialog") do
            backdrop
            div(**attrs) do
              yield

              render DialogClose.new
            end
          end
        end
      end

      def footer(*, **, &)
        render DialogFooter.new(*, **, &)
      end

      def header(*, **, &)
        render DialogHeader.new(*, **, &)
      end

      def middle(*, **, &)
        render DialogMiddle.new(*, **, &)
      end
      alias_method :body, :middle

      private

      def default_attrs
        {
          data_state: "open",
          class: [
            "fixed flex flex-col pointer-events-auto left-[50%] top-[50%] z-50 " \
            "w-full max-h-screen overflow-y-auto translate-x-[-50%] " \
            "translate-y-[-50%] gap-4 border bg-white dark:bg-gray-800 p-6 " \
            "shadow-lg duration-200 data-[state=open]:animate-in " \
            "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 " \
            "data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 " \
            "data-[state=open]:zoom-in-95 " \
            "data-[state=closed]:slide-out-to-left-1/2 " \
            "data-[state=closed]:slide-out-to-top-[48%] " \
            "data-[state=open]:slide-in-from-left-1/2 " \
            "data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg md:w-full",
            SIZES[@size]
          ]
        }
      end

      def backdrop
        div(
          data_state: "open",
          data_action: "click->ruby-ui--dialog#dismiss esc->ruby-ui--dialog#dismiss",
          class: "fixed pointer-events-auto inset-0 z-50 bg-background/80 " \
                "backdrop-blur-sm data-[state=open]:animate-in " \
                "data-[state=closed]:animate-out " \
                "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
        )
      end
    end
  end
end
