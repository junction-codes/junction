# frozen_string_literal: true

module Junction
  module Components
    module Avatar
      # UI component to display a fallback avatar when no image is available.
      class Fallback < Base
        def view_template(&)
          span(**attrs, &)
        end

        private

        def default_attrs
          {
            data: {
              ruby_ui__avatar_target: "fallback"
            },
            class: "absolute inset-0 flex items-center justify-center " \
                   "rounded-full bg-muted"
          }
        end
      end
    end
  end
end
