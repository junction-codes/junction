# frozen_string_literal: true

module Junction
  # Service to build plugin-defined routes into the main application router.
  class PluginRouteBuilder
    # Draws plugin-defined routes into the provided router.
    #
    # @param router [ActionDispatch::Routing::Mapper] The router to draw routes into.
    def self.draw(router)
      Junction::PluginRegistry.actions.each do |context, actions|
        resource_name = context.to_s.demodulize.underscore.pluralize

        router.scope(
          "/#{resource_name}/:namespace/:name",
          constraints: Junction::CatalogRouteConstraints::SLUG
        ) do
          actions.each do |action|
            name = helper_name(action, context)

            router.get(
              action[:path].present? ? action[:path] : name.to_s.gsub("_", "/"),
              to: "/#{action[:controller]}##{action[:action]}",
              as: name
            )
          end
        end
      end
    end

    private

    # Derives the helper name for a given action.
    #
    # @param action [Hash] The action definition.
    # @param context [Class] The entity class for the context.
    # @return [Symbol] The derived helper name.
    def self.helper_name(action, _context)
      action[:method].to_s.delete_suffix("_path").to_sym
    end
  end
end
