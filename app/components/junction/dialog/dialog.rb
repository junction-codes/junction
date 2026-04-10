# frozen_string_literal: true

module Junction
  module Components
    module Dialog
      # UI component to display a dialog container.
      class Dialog < Base
        def initialize(open: false, **user_attrs)
          @open = open

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs, &)
        end

        def trigger(...)
          render DialogTrigger.new(...)
        end

        def content(...)
          render DialogContent.new(...)
        end

        private

        def default_attrs
          {
            data: {
              controller: "ruby-ui--dialog",
              ruby_ui__dialog_open_value: @open
            }
          }
        end
      end
    end
  end
end
