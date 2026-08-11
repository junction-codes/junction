# frozen_string_literal: true

module Junction
  module Components
    module Avatar
      # UI component to display a user or entity's avatar image.
      class Image < Base
        def initialize(src:, alt: "", **user_attrs)
          @src = src
          @alt = alt

          super(**user_attrs)
        end

        def view_template
          img(**attrs)
        end

        private

        def default_attrs
          {
            # NB: do not set loading: "lazy" here. The avatar controller hides a
            # not-yet-loaded image with `display: none` (the `hidden` class) so
            # the fallback shows. The browser never fetches a `loading="lazy"`
            # image that generates no box, so its `load` event never fires and
            # the image stays hidden forever.
            data: {
              ruby_ui__avatar_target: "image",
              action: "load->ruby-ui--avatar#showImage " \
                      "error->ruby-ui--avatar#showFallback"
            },
            class: "relative aspect-square h-full w-full",
            alt: @alt,
            src: @src
          }
        end
      end
    end
  end
end
