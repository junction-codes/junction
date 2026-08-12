# frozen_string_literal: true

module Junction
  module Components
    module Users
      class UserAvatar < Base
        def initialize(user:, size: :md, **user_attrs)
          @user = user
          @size = size

          super(**user_attrs)
        end

        def view_template
          Avatar(**attrs) do |avatar|
            # The fallback is always rendered; the avatar controller swaps
            # between the two so a broken or slow image URL still shows it. The
            # actual image comes last so it paints over the fallback even if the
            # controller never runs.
            avatar.fallback { icon("circle-user-round") }
            avatar.image(src: @user.image_url, alt: @user.title) if @user.image_url.present?
          end
        end

        private

        def default_attrs
          {
            size: @size
          }
        end
      end
    end
  end
end
