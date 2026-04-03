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
          if @entity.image_url.present?
            img(
              src: @entity.image_url,
              alt: t(".logo_alt", name: @entity.name),
              class: "h-12 w-12 rounded-md object-cover flex-shrink-0"
            )
          else
            div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
              icon(@entity.icon, class: "h-6 w-6 text-gray-500")
            end
          end

          div do
            div(class: "text-sm font-medium text-gray-900 dark:text-white") do
              render_view_link(@entity, class: "ps-0")
            end

            div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") do
              plain @entity.description
            end
          end
        end
      end

      private

      def default_attrs
        { class: "flex items-center space-x-4" }
      end
    end
  end
end
