# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # A link to an entity's page.
      #
      # Renders the entity's title as a link when the current has permission to
      # view it, or as plain text otherwise.
      #
      # Plain text rather than a disabled link. An `<a>` is still a link to the
      # keyboard and a screen reader, it just goes nowhere.
      #
      # @example
      #   EntityLink(entity: owner, class: "font-medium")
      class EntityLink < Base
        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity to link to.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity:, **user_attrs)
          @entity = entity

          super(**user_attrs)
        end

        def view_template
          if allowed_to?(:show?, @entity)
            Link(href: junction_catalog_path(@entity), variant: :text,
                 data: { turbo_frame: "_top" }, **attrs) { @entity.title }
          else
            span(**attrs) { @entity.title }
          end
        end

        private

        def default_attrs
          { class: "text-accent-strong" }
        end
      end
    end
  end
end
