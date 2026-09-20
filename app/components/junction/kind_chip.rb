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
      # Chip tint per kind. Written out because Tailwind can't see a class name
      # assembled from the kind at runtime.
      TINTS = {
        "Domain" => "bg-kind-domain text-kind-domain-fg",
        "System" => "bg-kind-system text-kind-system-fg",
        "Component" => "bg-kind-component text-kind-component-fg",
        "Api" => "bg-kind-api text-kind-api-fg",
        "Resource" => "bg-kind-resource text-kind-resource-fg",
        "Group" => "bg-kind-group text-kind-group-fg",
        "User" => "bg-kind-user text-kind-user-fg",
        "Template" => "bg-kind-template text-kind-template-fg",
        "Location" => "bg-kind-location text-kind-location-fg"
      }.freeze

      NEUTRAL = "bg-subtle text-text-body"

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
      # @param user_attrs [Hash] Additional HTML attributes.
      def initialize(entity:, size: :md, **user_attrs)
        @entity = entity
        @box, @glyph = SIZES.fetch(size)

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
        return { class: "#{@box} object-cover shrink-0" } if image?

        { class: "#{@box} shrink-0 flex items-center justify-center " \
                 "#{TINTS.fetch(@entity.kind, NEUTRAL)}" }
      end
    end
  end
end
