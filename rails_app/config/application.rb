# frozen_string_literal: true

require_relative "boot"

require "rails/all"

require_relative "../../lib/junction/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JunctionApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Include engine migrations so db:migrate works without a separate install step.
    config.paths["db/migrate"] << Junction::Engine.root.join("db/migrate")

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
