# frozen_string_literal: true

require "rails_icons"

RailsIcons.configure do |config|
  config.icons_path = Rails.root.join("app/assets/svg/icons")

  config.default_library = "lucide"
  config.default_variant = "outline"

  config.libraries.boxicons.default_variant = "logos"
  config.libraries.lucide.default_variant = "outline"
end
