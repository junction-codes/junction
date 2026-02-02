# frozen_string_literal: true

module Junction
  # Base controller for plugin controllers.
  #
  # Plugins should inherit from this class to automatically get access to
  # Junction's helpers and default settings.
  #
  # @abstract
  class PluginController < ActionController::Base
    include Authentication
    include PluginDispatchHelper
    include Engine.routes.url_helpers

    allow_browser versions: :modern

    # We're using Phlex, so we don't need ActionView to render layouts.
    layout false

    add_flash_types :success

    private

    # The class of the entity being managed.
    #
    # @return [Class<ApplicationRecord>] The entity class.
    #
    # @raise [NotImplementedError] If not implemented in the current subclass.
    def entity_class
      raise NotImplementedError, "#{self.class} must define #entity_class"
    end

    # Key for the key for the entity id in the parameters.
    #
    # @return [String] The parameter key.
    def entity_key
      "#{entity_class.model_name.element}_id"
    end

    # Set the entity based on the context and parameters.
    #
    # @return [ApplicationRecord] The found entity.
    def set_entity
      @entity = entity_class.find(params[entity_key])
    end
  end
end
