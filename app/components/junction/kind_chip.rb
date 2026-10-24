# frozen_string_literal: true

module Junction
  module Components
    # An entity's image, or its kind's icon where it has none.
    #
    # Shared by the listing rows and the entity page header, so a kind reads
    # the same wherever it appears.
    #
    # @example
    #   KindChip(entity:, size: :lg)
    class KindChip < Base
      # The color for each kind, for a glyph that carries no fill of its own.
      FOREGROUNDS = {
        "Domain" => "text-kind-domain-fg",
        "System" => "text-kind-system-fg",
        "Component" => "text-kind-component-fg",
        "Api" => "text-kind-api-fg",
        "Resource" => "text-kind-resource-fg",
        "Group" => "text-kind-group-fg",
        "User" => "text-kind-user-fg",
        "Template" => "text-kind-template-fg",
        "Location" => "text-kind-location-fg"
      }.freeze

      # Chip tint per kind.
      TINTS = {
        "Domain" => "bg-kind-domain",
        "System" => "bg-kind-system",
        "Component" => "bg-kind-component",
        "Api" => "bg-kind-api",
        "Resource" => "bg-kind-resource",
        "Group" => "bg-kind-group",
        "User" => "bg-kind-user",
        "Template" => "bg-kind-template",
        "Location" => "bg-kind-location"
      }.to_h { |kind, fill| [ kind, "#{fill} #{FOREGROUNDS.fetch(kind)}" ] }.freeze

      # The ring border around the chip.
      RINGS = {
        "Domain" => "ring-1 ring-kind-domain-fg",
        "System" => "ring-1 ring-kind-system-fg",
        "Component" => "ring-1 ring-kind-component-fg",
        "Api" => "ring-1 ring-kind-api-fg",
        "Resource" => "ring-1 ring-kind-resource-fg",
        "Group" => "ring-1 ring-kind-group-fg",
        "User" => "ring-1 ring-kind-user-fg",
        "Template" => "ring-1 ring-kind-template-fg",
        "Location" => "ring-1 ring-kind-location-fg"
      }.freeze

      NEUTRAL = "bg-subtle text-text-body"
      NEUTRAL_RING = "ring-1 ring-border-strong"

      # Box and glyph classes per size.
      SIZES = {
        xs: [ "h-5 w-5 rounded-full", "h-3 w-3" ],
        md: [ "h-7 w-7 rounded-lg", "h-4 w-4" ],
        lg: [ "h-12 w-12 rounded-xl", "h-6 w-6" ]
      }.freeze

      # Initializes a new component.
      #
      # @param entity [Junction::Entity] The entity.
      # @param size [Symbol] One of {SIZES}.
      # @param ring [Boolean] Whether to add a ring border around the chip.
      # @param user_attrs [Hash] Additional HTML attributes.
      def initialize(entity:, size: :md, ring: false, **user_attrs)
        @entity = entity
        @box, @glyph = SIZES.fetch(size)
        @ring = ring

        super(**user_attrs)
      end

      def view_template
        if image?
          img(src: @entity.image_url, alt: t(".logo_alt", name: @entity.title),
              **attrs)
        else
          div(**attrs) do
            icon(@entity.icon, fallback: Junction::Kind::DEFAULT_ICON,
                 class: @glyph)
          end
        end
      end

      private

      # Whether the entity has a custom image configured.
      #
      # @return [Boolean] Whether the entity brings an image of its own.
      def image?
        @entity.image_url.present?
      end

      def default_attrs
        return { class: "#{@box} object-cover shrink-0 #{ring_classes}" } if image?

        { class: "#{@box} shrink-0 flex items-center justify-center " \
                 "#{TINTS.fetch(@entity.kind, NEUTRAL)} #{ring_classes}" }
      end

      # The ring around the chip.
      #
      # @return [String] The classes.
      def ring_classes
        return "" unless @ring

        RINGS.fetch(@entity.kind, NEUTRAL_RING)
      end
    end
  end
end
