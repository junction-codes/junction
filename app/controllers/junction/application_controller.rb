# frozen_string_literal: true

module Junction
  # Base controller for the Junction engine.
  #
  # @abstract
  class ApplicationController < PluginController
    private

    # Scopes that have namespace/name routes.
    #
    # @return [Array<String>] The sluggable scopes.
    def sluggable_scopes
      Junction::Kinds.sluggable.map { |kind| kind.scope.to_s }
    end

    def catalog_entity_class(scope)
      Junction::Kinds.by_scope(scope)&.model
    end

    def sanitize_catalog_scope(attrs)
      return attrs unless attrs.include?(:catalog_scope)
      return attrs if sluggable_scopes.include?(attrs.expect(:catalog_scope))

      out = attrs.dup
      out.delete(:catalog_scope)
      out
    end
  end
end
