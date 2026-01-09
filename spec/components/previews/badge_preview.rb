class BadgePreview < Lookbook::Preview
  layout "lookbook"

  # @!group Variants
  # @label Primary (Default)
  def primary
    render Components::Badge.new(variant: :primary) { "Primary Badge" }
  end

  def secondary
    render Components::Badge.new(variant: :secondary) { "Secondary Badge" }
  end

  def active
    render Components::Badge.new(variant: :active) { "Active Badge" }
  end

  def closed
    render Components::Badge.new(variant: :closed) { "Closed Badge" }
  end

  def success
    render Components::Badge.new(variant: :success) { "Success Badge" }
  end

  def warning
    render Components::Badge.new(variant: :warning) { "Warning Badge" }
  end

  def destructive
    render Components::Badge.new(variant: :destructive) { "Destructive Badge" }
  end

  def outline
    render Components::Badge.new(variant: :outline) { "Outline Badge" }
  end

  # @!endgroup

  # @!group Sizes
  def small
    render Components::Badge.new(size: :sm) { "Small Badge" }
  end

  # @label Medium (Default)
  def medium
    render Components::Badge.new(size: :md) { "Medium Badge" }
  end

  def large
    render Components::Badge.new(size: :lg) { "Large Badge" }
  end
  # @!endgroup

  # @param text text "Text to display inside the badge"
  # @param size select [sm, md, lg,] "Size of the badge"
  # @param variant select [active, closed, danger, deprecated, destructive,
  #   experimental, outline, primary, production, secondary, success, warning,
  #
  #   amber, cyan, emerald, fuchsia, gray, green, indigo, lime, neutral,
  #   orange, pink, purple, red, rose, sky, slate, stone, teal, violet,
  #   yellow, zinc] "Badge variant"
  def playground(text: "Playground", size: :md, variant: :primary)
    render Components::Badge.new(variant:, size:) { text }
  end
end
