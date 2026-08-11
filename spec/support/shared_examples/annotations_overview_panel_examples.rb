# frozen_string_literal: true

# Shared examples for annotations overview panel hashes.
#
# @param required_keys [Array<Symbol>] Keys the panel must include.
RSpec.shared_examples "an annotations overview panel" do |required_keys|
  required_keys.each do |key|
    it "includes #{key}" do
      expect(panel).to have_key(key)
    end
  end
end
