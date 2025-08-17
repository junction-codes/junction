# frozen_string_literal: true

module IconHelper
  extend RailsIcons::Helpers::IconHelper

  def icon(name, library: RailsIcons.configuration.default_library, variant: nil, **arguments)
    library, name, variant = name.split(":", 3) if name.include?(":")

    super(name, library:, variant:, **arguments)
  end
end
