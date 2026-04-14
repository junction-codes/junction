# frozen_string_literal: true

module Junction
  # Route constraints aligned with {Sluggable} validation formats (keep in sync).
  module SluggableRouteConstraints
    # Routing cannot use `\A`/`\z` anchors (Rails raises); model validations use anchored regexes.
    NAMESPACE_FORMAT = /[a-z][a-z0-9\-]*/.freeze
    SLUG_FORMAT = /[a-zA-Z][a-zA-Z0-9\-_.]*/.freeze

    SLUG = {
      namespace: NAMESPACE_FORMAT,
      name: SLUG_FORMAT
    }.freeze

    NUMERIC_ID = /\d+/
  end
end
