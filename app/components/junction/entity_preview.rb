# frozen_string_literal: true

module Junction
  module Components
    # Renders a compact preview of a catalog entity.
    #
    # @example
    #   EntityPreview(entity:)
    class EntityPreview < Base
      # Chip tint per kind.
      CHIPS = {
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

      NEUTRAL_CHIP = "bg-subtle text-text-body"

      # Initializes a new component.
      #
      # @param entity [ApplicationRecord] Entity to preview.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(entity:, **user_attrs)
        @entity = entity

        super(**user_attrs)
      end

      def view_template
        div(**attrs) do
          chip

          div(class: "min-w-0") do
            div(class: "text-[13.5px] font-semibold text-foreground truncate") do
              render_view_link(@entity, class: "ps-0 h-auto p-0 text-inherit")
            end

            subtitle
          end
        end
      end

      private

      # The entity's own image where it has one, and its kind's tinted glyph
      # where it does not.
      def chip
        if @entity.image_url.present?
          img(src: @entity.image_url, alt: t(".logo_alt", name: @entity.title),
              class: "h-7 w-7 rounded-lg object-cover shrink-0")
        else
          div(class: "h-7 w-7 rounded-lg shrink-0 flex items-center " \
                     "justify-center #{chip_classes}") do
            icon(@entity.icon, fallback: Junction::Kind::DEFAULT_ICON,
                 class: "h-4 w-4")
          end
        end
      end

      def subtitle
        return if @entity.preview_subtitle.blank?

        div(class: "text-[11.5px] text-muted-foreground truncate") do
          plain @entity.preview_subtitle
        end
      end

      # @return [String] The chip's tint for this entity's kind.
      def chip_classes
        CHIPS.fetch(@entity.kind, NEUTRAL_CHIP)
      end

      def default_attrs
        { class: "flex items-center gap-3 min-w-0" }
      end
    end
  end
end
