# frozen_string_literal: true

module Junction
  module IconHelper
    extend RailsIcons::Helpers::IconHelper

    # An icon name is joined into a filesystem path and read, so anything that
    # is not a plain slug, optionally qualified as `library:name:variant`, is
    # refused before it reaches disk. Without this, a name from a plugin or the
    # database can walk out of the icon directory, and one that lands on a
    # readable file that is not an icon fails in a way `fallback` cannot catch.
    SAFE_NAME = /\A[A-Za-z0-9_-]+(?::[A-Za-z0-9_-]+){0,2}\z/

    # Renders an icon.
    #
    # Icon names can be passed as the bare name, or qualified as
    # `library:name:variant`. This is useful where icons are defined as a string
    # and couldn't otherwise specify a different icon library or variant. When
    # the name is qualified, the `library` and `variant` arguments are ignored.
    #
    # Icons are read off disk, so a name that doesn't resolve raises and takes
    # the whole page down with it. Pass `fallback` for any name that's not
    # defined in the codebase, such as catalog options, a kind's `default_icon`,
    # a plugin, etc., so that  missing icon degrades instead of erroring.
    #
    # The fallback is rendered without one of its own, so it has to be a real
    # icon. A typo in the fallback will still raise rather than failing
    # silently.
    #
    # @param name [String] The icon to render, optionally qualified as
    #   `library:name:variant`.
    # @param library [String] Icon library to read from.
    # @param variant [String] Variant within the library.
    # @param fallback [String] Icon to use when `name` is blank or does not
    #   resolve. Without one, an unknown name raises.
    # @param arguments [Hash] Attributes for the rendered SVG.
    # @return [String] The rendered icon.
    #
    # @raise [Icons::IconNotFound] If the name is invalid or does not resolve
    #   and no fallback was given, or if the fallback does not resolve either.
    def icon(name, library: RailsIcons.configuration.default_library,
             variant: nil, fallback: nil, **arguments)
      name = fallback if name.blank? && fallback.present?
      name = name.to_s

      raise Icons::IconNotFound, "Invalid icon name #{name.inspect}" unless
        name.match?(SAFE_NAME)

      library, name, variant = name.split(":", 3) if name.include?(":")

      super(name, library:, variant:, **arguments)
    rescue Icons::IconNotFound
      raise if fallback.blank? || name == fallback

      icon(fallback, **arguments)
    end
  end
end
