class AvatarPreview < Lookbook::Preview
  layout "lookbook"

  IMAGE_URL = "https://github.com/junction-codes.png"

  # @!group Sizes
  def extra_small
    render Components::Avatar.new(size: :xs) do
      Components::AvatarImage(src: IMAGE_URL, alt: "Extra Small Avatar")
    end
  end

  def small
    render Components::Avatar.new(size: :sm) do
      Components::AvatarImage(src: IMAGE_URL, alt: "Small Avatar")
    end
  end

  # @label Medium (Default)
  def medium
    render Components::Avatar.new(size: :md) do
      Components::AvatarImage(src: IMAGE_URL, alt: "Medium Avatar")
    end
  end

  def large
    render Components::Avatar.new(size: :lg) do
      Components::AvatarImage(src: IMAGE_URL, alt: "Large Avatar")
    end
  end

  def extra_large
    render Components::Avatar.new(size: :xl) do
      Components::AvatarImage(src: IMAGE_URL, alt: "Extra Large Avatar")
    end
  end
  # @!endgroup

  # Fallback
  # --------
  # Display text, such as a user's initials, when no image is available.
  #
  # @label Fallback
  # @todo Add a fallback with icon example.
  def fallback_with_text
    render Components::Avatar.new(size: :md) do
      Components::AvatarFallback { "JC" }
    end
  end

  # @param alt text "Alternative text to display for the avatar image"
  # @param size select [xs, sm, md, lg, xl] "Size of the avatar"
  # @param image_url text "URL of the avatar image"
  # @param fallback text "Fallback text to display when the image_url is empty"
  def playground(alt: "Playground Avatar", size: :md, image_url: IMAGE_URL, fallback: "PA")
    render Components::Avatar.new(size:) do
      if image_url.present?
        Components::AvatarImage(src: image_url, alt:)
      else
        Components::AvatarFallback { fallback }
      end
    end
  end
end
