# frozen_string_literal: true

# Service to build plugin-defined routes into the main application router.
class PluginRouteBuilder
  # Draws plugin-defined routes into the provided router.
  #
  # @param router [ActionDispatch::Routing::Mapper] The router to draw routes into.
  def self.draw(router)
    PluginRegistry.actions.each do |context, actions|
      # Re-open the existing resource block in the router to add plugin actions.
      resource_name = context.to_s.underscore.pluralize.to_sym
      router.resources resource_name do
        actions.each do |action|
          name = helper_name(action)

          router.get(
            action[:path].present? ? action[:path] : name.to_s.gsub("_", "/"),
            to: "#{action[:controller]}##{action[:action]}",
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
  # @return [Symbol] The derived helper name.
  def helper_name(action)
    action[:method].to_s.delete_prefix("#{context.to_s.underscore}_")
                        .delete_suffix("_path")
                        .to_sym
  end
end
