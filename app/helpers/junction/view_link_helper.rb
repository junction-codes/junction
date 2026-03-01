# frozen_string_literal: true

module Junction
  # Helpers for rendering entity links with authorization.
  module ViewLinkHelper
    # Renders a link to the given entity.
    #
    # If the current user does not have access to the entity, the link is
    # disabled.
    #
    # @param entity [ApplicationRecord] The entity to link to.
    # @param user_attrs [Hash] Additional HTML attributes for the link.
    #
    # @todo Add a proper tooltip to the disabled link.
    def render_view_link(entity, **user_attrs)
      return if entity.blank?

      if allowed_to?(:show?, entity)
        Components::Link(href: url_for(entity), variant: :link, **user_attrs) { entity.name }
      else
        Components::Link(
          href: nil,
          variant: :disabled,
          title: "You do not have access to this #{entity.class.model_name.human}",
          **user_attrs
        ) { entity.name }
      end
    end
  end
end
