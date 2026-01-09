class LinkPreview < Lookbook::Preview
  layout "lookbook"

  # @!group Variants
  # @label Link (Default)
  def link
    render Components::Link.new { "Link Link" }
  end

  def primary
    render Components::Link.new(variant: :primary) { "Primary Link" }
  end

  def secondary
    render Components::Link.new(variant: :secondary) { "Secondary Link" }
  end

  def destructive
    render Components::Link.new(variant: :destructive) { "Destructive Link" }
  end

  def outline
    render Components::Link.new(variant: :outline) { "Outline Link" }
  end

  def ghost
    render Components::Link.new(variant: :ghost) { "Ghost Link" }
  end

  def disabled
    render Components::Link.new(variant: :disabled) { "Disabled Link" }
  end
  # @!endgroup

  # @!group Sizes
  def small
    render Components::Link.new(size: :sm) { "Small Link" }
  end

  # @label Medium (Default)
  def medium
    render Components::Link.new(size: :md) { "Medium Link" }
  end

  def large
    render Components::Link.new(size: :lg) { "Large Link" }
  end

  def extra_large
    render Components::Link.new(size: :xl) { "Extra Large Link" }
  end
  # @!endgroup

  # @param text text "Text to display inside the link"
  # @param size select [sm, md, lg, xl] "Size of the link"
  # @param variant select [link, primary, secondary, destructive, outline,
  #   ghost, disabled] "Link variant"
  #
  # @todo Add icon parameter when https://github.com/lookbook-hq/lookbook/issues/759
  #   is resolved.
  def playground(text: "Playground Link", size: :md, variant: :link)
    render Components::Link.new(variant:, size:) { text }
  end
end
