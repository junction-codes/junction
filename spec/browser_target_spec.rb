# frozen_string_literal: true

require "rails_helper"

# The browser the system specs drive is chosen while `spec/support/browser.rb`
# loads, so the host needs to be a valid URI host or the entire suite will fail.
RSpec.describe BrowserTarget do
  describe "#resolved" do
    it "leaves a dotted address alone" do
      expect(described_class.resolved("172.18.0.5")).to eq("172.18.0.5")
    end

    it "leaves localhost alone" do
      expect(described_class.resolved("localhost")).to eq("localhost")
    end

    it "resolves a service name to its address" do
      allow(described_class).to receive(:address_of).with("chrome").and_return("172.18.0.5")

      expect(described_class.resolved("chrome")).to eq("172.18.0.5")
    end

    it "brackets an address that resolves to IPv6" do
      allow(described_class).to receive(:address_of).with("chrome").and_return("::1")

      expect(described_class.resolved("chrome")).to eq("[::1]")
    end

    it "gives a URI a host it accepts" do
      allow(described_class).to receive(:address_of).with("chrome").and_return("::1")
      uri = URI.parse("http://chrome:9222")

      expect { uri.host = described_class.resolved("chrome") }.not_to raise_error
    end
  end
end
