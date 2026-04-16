# frozen_string_literal: true

module Junction
  # Base controller for the Junction engine.
  #
  # @abstract
  class ApplicationController < PluginController
    CATALOG_SCOPES = %w[api component domain group resource role system user].freeze

    private

    def sanitize_catalog_scope(attrs)
      return attrs unless attrs.key?(:catalog_scope)
      return attrs unless CATALOG_SCOPES.include?(attrs.expect(:catalog_scope))

      out = attrs.dup
      out.delete(:catalog_scope)
      out
    end

    def route_params
      sanitize_catalog_scope(params.expect(:catalog_scope, :namespace, :name))
    end
  end
end
