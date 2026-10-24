# frozen_string_literal: true

require "capybara/cuprite"
require "socket"

# The browser the system specs drive.
#
# With `CHROME_URL` set, the specs drive a browser remotely. Without it they
# launch a local binary.
module BrowserTarget
  extend self

  # Remote browser URL, if set.
  #
  # Chrome refuses a DevTools request whose Host header is neither an IP nor
  # localhost, so a service name is resolved before Ferrum is handed it.
  #
  # @return [String, nil] The CDP endpoint.
  def url
    return @url if defined?(@url)

    @url = ENV["CHROME_URL"].presence&.then do |value|
      uri = URI.parse(value)
      uri.host = resolved(uri.host)
      uri.to_s
    end
  end

  # The host to put in the URL Ferrum is handed.
  #
  # Chrome refuses a DevTools request whose Host header is neither an IP nor
  # localhost, so a service name is resolved to an address first. localhost
  # is already accepted and needs none, and an address that resolves to IPv6
  # has to be bracketed to be a valid URI host.
  #
  # @param host [String] The host named by `CHROME_URL`.
  # @return [String] The host to connect to.
  def resolved(host)
    return host if host == "localhost" || host.match?(/\A[\d.]+\z/) || host.start_with?("[")

    address = address_of(host)

    address.include?(":") ? "[#{address}]" : address
  end

  # Resolves the host to an IP address.
  #
  # @param host [String] The host to resolve.
  # @return [String] Resolved IP address.
  def address_of(host)
    IPSocket.getaddress(host)
  rescue SocketError, Socket::ResolutionError
    abort <<~MESSAGE
      CHROME_URL is set, but #{host} could not be resolved. Ensure the host is
      reachable and the remote browser is running, or unset CHROME_URL to use a
      local browser.
    MESSAGE
  end

  # Whether the browser runs outside this system.
  #
  # @return [Boolean] Whether or not the browser is remote.
  def remote?
    !url.nil?
  end

  # The options both the registered driver and `driven_by` are built from.
  #
  # @return [Hash] The options.
  def options
    return { url: } if remote?

    {
      process_timeout: 30,
      # Keep CI/container runs stable; opt in when actively debugging.
      inspector: false,
      # Set to false for debugging.
      headless: true,
      browser_options: {
        # Required for Docker/CI environments.
        'no-sandbox': nil,
        # Helpful in CI environments to avoid limited resource problems.
        'disable-gpu': nil,
        'disable-dev-shm-usage': nil
      }
    }
  end

  # This system's address on the network the browser shares with it.
  #
  # @return [String] The system's IP address.
  def app_address
    ENV["CAPYBARA_APP_HOST"].presence ||
      Socket.ip_address_list.find { |a| a.ipv4? && !a.ipv4_loopback? }&.ip_address ||
      "127.0.0.1"
  end
end

# Let fill_in/find_field match on aria-label, matching how assistive tech
# computes accessible names for inputs that rely on aria-label instead of a
# visible <label>.
Capybara.enable_aria_label = true

if BrowserTarget.remote?
  Capybara.server_host = "0.0.0.0"
  Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", 45_678).to_i
  Capybara.app_host = "http://#{BrowserTarget.app_address}:#{Capybara.server_port}"
end

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [ 1400, 900 ], **BrowserTarget.options)
end

Capybara.javascript_driver = :cuprite

RSpec.configure do |config|
  config.prepend_before(:each, :js, type: :system) do
    driven_by :cuprite, screen_size: [ 1400, 900 ], options: BrowserTarget.options
  end
end
