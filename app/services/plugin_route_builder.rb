# frozen_string_literal: true

class PluginRouteBuilder
  def self.draw(router)
    registry = PluginRegistry.instance
    actions_by_context = registry.routable_actions_grouped_by_context

    actions_by_context.each do |context_class_name, actions|
      # e.g., "System" -> :systems
      resource_name = context_class_name.underscore.pluralize.to_sym

      # Re-open the existing resource block in the router
      router.resources resource_name do
        actions.each do |action_details|
          # Derives the route helper name from the path_method symbol.
          #
          # example: :system_github_actions_path -> :github_actions
          as_name = action_details[:path_method].to_s
                                                .delete_prefix("#{context_class_name.underscore}_")
                                                .delete_suffix("_path")
                                                .to_sym
          path_segment = action_details[:path].present? ? action_details[:path] : as_name.to_s.gsub("_", "/")

          router.get(
            path_segment,
            to: "#{action_details[:controller]}##{action_details[:action]}",
            as: as_name
          )
        end
      end
    end
  end
end
