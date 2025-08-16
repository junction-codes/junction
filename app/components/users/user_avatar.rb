# frozen_string_literal: true

module Components
  class UserAvatar < Base
    def initialize(user:, size: :md, **user_attrs)
      @user = user
      @size = size

      super(**user_attrs)
    end

    def view_template
      Avatar(**attrs) do
        if @user.image_url.present?
          AvatarImage(src: @user.image_url, alt: @user.display_name)
        else
          AvatarFallback { icon("circle-user-round") }
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
