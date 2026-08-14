# frozen_string_literal: true

require "factory_bot_rails"

# Default +image_url+ for factories.
#
# Models validate this as an absolute http(s) URL, so it cannot be a relative
# path. In system specs the browser fetches whatever is here, and an externally
# resolvable host (or a Faker-generated one) means a real DNS lookup and
# connection attempt on every page load. That is slow, and under load it fails
# outright with Ferrum::PendingConnectionsError. Loopback on the default HTTP
# port is refused immediately with no DNS involved.
#
# Specs that need a *failing* image load should set their own URL rather than
# relying on this one.
TEST_IMAGE_URL = "http://127.0.0.1/icon.png"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
