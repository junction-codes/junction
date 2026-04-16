# frozen_string_literal: true

module Junction
  # Base controller for the Junction engine.
  #
  # @abstract
  class ApplicationController < PluginController
    CATALOG_SCOPES = %w[api component domain group resource role system user].freeze

    private

    def catalog_entity_class(scope)
      Junction.const_get(scope.to_s.classify)
    end

    def sanitize_catalog_scope(attrs)
      return attrs unless attrs.include?(:catalog_scope)
      return attrs if CATALOG_SCOPES.include?(attrs.expect(:catalog_scope))

      out = attrs.dup
      out.delete(:catalog_scope)
      out
    end
  end
end
