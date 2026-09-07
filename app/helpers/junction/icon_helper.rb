# frozen_string_literal: true

module Junction
  module IconHelper
    extend RailsIcons::Helpers::IconHelper

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
    # @raise [Icons::IconNotFound] If the name does not resolve and no fallback
    #   was given, or if the fallback does not resolve either.
    def icon(name, library: RailsIcons.configuration.default_library,
             variant: nil, fallback: nil, **arguments)
      name = fallback if name.blank?
      library, name, variant = name.split(":", 3) if name.include?(":")

      super(name, library:, variant:, **arguments)
    rescue Icons::IconNotFound
      raise if fallback.blank? || name == fallback

      icon(fallback, **arguments)
    end
  end
end
