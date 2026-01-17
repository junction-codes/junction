# frozen_string_literal: true

module Junction
  module Components
    class UserAvatar < Base
      def initialize(user:, size: :md, **user_attrs)
        @user = user
        @size = size

        super(**user_attrs)
      end

      def view_template
        Avatar(**attrs) do |avatar|
          if @user.image_url.present?
            avatar.image(src: @user.image_url, alt: @user.display_name)
          else
            avatar.fallback { icon("circle-user-round") }
          end
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
