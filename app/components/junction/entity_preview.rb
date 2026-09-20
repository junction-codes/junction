# frozen_string_literal: true

module Junction
  module Components
    # Renders a compact preview of a catalog entity.
    #
    # @example
    #   EntityPreview(entity:)
    class EntityPreview < Base
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
          KindChip(entity: @entity)

          div(class: "min-w-0") do
            div(class: "text-[13.5px] font-semibold text-foreground truncate") do
              EntityLink(entity: @entity, class: "text-foreground")
            end

            subtitle
          end
        end
      end

      private

      def subtitle
        return if @entity.preview_subtitle.blank?

        div(class: "text-[11.5px] text-muted-foreground truncate") do
          plain @entity.preview_subtitle
        end
      end

      def default_attrs
        { class: "flex items-center gap-3 min-w-0" }
      end
    end
  end
end
