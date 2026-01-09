class ButtonPreview < Lookbook::Preview
  layout "lookbook"

  # @!group Variants
  # @label Primary (Default)
  def primary
    render Components::Button.new { "Primary Button" }
  end

  def secondary
    render Components::Button.new(variant: :secondary) { "Secondary Button" }
  end

  def destructive
    render Components::Button.new(variant: :destructive) { "Destructive Button" }
  end

  def outline
    render Components::Button.new(variant: :outline) { "Outline Button" }
  end

  def ghost
    render Components::Button.new(variant: :ghost) { "Ghost Button" }
  end

  def link
    render Components::Button.new(variant: :link) { "Link Button" }
  end
  # @!endgroup

  # @!group Sizes
  def small
    render Components::Button.new(size: :sm) { "Small Button" }
  end

  # @label Medium (Default)
  def medium
    render Components::Button.new(size: :md) { "Medium Button" }
  end

  def large
    render Components::Button.new(size: :lg) { "Large Button" }
  end

  def extra_large
    render Components::Button.new(size: :xl) { "Extra Large Button" }
  end
  # @!endgroup

  # @param text text "Text to display inside the button"
  # @param size select [sm, md, lg, xl] "Size of the button"
  # @param variant select [primary, secondary, destructive, outline, ghost,
  #   link] "Button variant"
  # @param disabled toggle "Whether the button should be disabled"
  #
  # @todo Add icon parameter when https://github.com/lookbook-hq/lookbook/issues/759
  #   is resolved.
  def playground(text: "Playground Button", size: :md, variant: :primary, disabled: false)
    render Components::Button.new(variant:, size:, disabled:) { text }
  end
end
