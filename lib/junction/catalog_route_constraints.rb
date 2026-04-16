# frozen_string_literal: true

module Junction
  # Constrains for catalog routes that use "friendly" routes with namespace and
  # name segments (e.g. /apis/:namespace/:name).
  module CatalogRouteConstraints
    NAMESPACE_FORMAT = /[a-z][a-z0-9\-]{0,62}/.freeze
    NAME_FORMAT = /[a-zA-Z][a-zA-Z0-9\-_.]{0,62}/.freeze

    SLUG = {
      namespace: NAMESPACE_FORMAT,
      name: NAME_FORMAT
    }.freeze
  end
end
